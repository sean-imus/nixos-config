{ inputs, ... }:
{
  # Use disko for declarative disk configuration
  flake-file.inputs = {
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # Storage layout as a reusable mechanism every host imports explicitly
  flake.modules.nixos.disko =
    { config, lib, ... }:
    let
      cfg = config.diskoCfg;

      # Hibernating hosts get RAM + 2G headroom, everyone else sets their own
      swapSize = if cfg.hibernationSupport then "${toString (cfg.memorySize + 2)}G" else cfg.swapSize;

      btrfs = {
        type = "btrfs";
        extraArgs = [ "-f" ];
        # The two subvolumes that survive every boot
        subvolumes = {
          "/nix" = {
            mountpoint = "/nix";
            mountOptions = [
              "compress=zstd"
              "noatime"
            ];
          };
          "/persist" = {
            mountpoint = "/persist";
            mountOptions = [
              "compress=zstd"
              "noatime"
            ];
          };
        };
      };

      swap = {
        type = "swap";
        # Only hibernating hosts actually need a resume device
        resumeDevice = cfg.hibernationSupport;
      };

      # Wrap any content in LUKS without repeating the boilerplate
      luks = name: content: {
        type = "luks";
        inherit name;
        settings.allowDiscards = true;
        inherit content;
      };

      # Encrypted hosts split root & swap into two LUKS partitions
      dataPartitions =
        if cfg.encrypt then
          {
            luks = {
              end = "-${swapSize}";
              content = luks "cryptroot" btrfs;
            };
            cryptswap = {
              size = swapSize;
              content = luks "cryptswap" swap;
            };
          }
        else
          {
            root = {
              end = "-${swapSize}";
              content = btrfs;
            };
            swap = {
              size = swapSize;
              content = swap;
            };
          };
    in
    {
      # Import diskos NixOS module to use its options
      imports = [ inputs.disko.nixosModules.disko ];

      # Create options for the hosts, only device is hard-required
      options.diskoCfg = {
        device = lib.mkOption {
          type = lib.types.str;
        };
        encrypt = lib.mkOption {
          type = lib.types.bool;
          default = true;
        };
        hibernationSupport = lib.mkOption {
          type = lib.types.bool;
          default = true;
        };
        memorySize = lib.mkOption {
          type = lib.types.nullOr lib.types.int;
          default = null;
        };
        swapSize = lib.mkOption {
          type = lib.types.str;
          default = "4G";
        };
        tmpfsSize = lib.mkOption {
          type = lib.types.str;
          default = "4G";
        };
      };

      config = {
        assertions = [
          {
            # Throw an error if hosts that want to hibernate don't declare their memory size
            assertion = !cfg.hibernationSupport || cfg.memorySize != null;
            message = "diskoCfg.memorySize must be set on hibernating hosts";
          }
        ];

        # Boot needs both the store and the age key from disk
        fileSystems."/nix".neededForBoot = true;
        fileSystems."/persist".neededForBoot = true;

        # Actual disko configuration that creates /boot and imports the other partitions from above
        disko.devices = {
          disk.main = {
            type = "disk";
            device = cfg.device;
            content = {
              type = "gpt";
              partitions = {
                ESP = {
                  size = "1G";
                  type = "EF00";
                  content = {
                    type = "filesystem";
                    format = "vfat";
                    mountpoint = "/boot";
                    mountOptions = [ "umask=0077" ];
                  };
                };
              }
              # Import data partitions
              // dataPartitions;
            };
          };

          # Root is stored in RAM, everything persistent is opt-in on disk
          nodev."/" = {
            fsType = "tmpfs";
            mountOptions = [
              "size=${cfg.tmpfsSize}"
              "mode=755"
            ];
          };
        };
      };
    };
}
