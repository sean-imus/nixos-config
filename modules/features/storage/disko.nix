{ lib, ... }:
{
  flake-file.inputs = {
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.modules.nixos.disko =
    { config, ... }:
    let
      cfg = config.diskoCfg;

      btrfs = {
        type = "btrfs";
        extraArgs = [ "-f" ];
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
        resumeDevice = true;
      };

      luks = name: content: {
        type = "luks";
        inherit name;
        settings.allowDiscards = true;
        inherit content;
      };

      dataPartitions =
        if cfg.encrypt then
          {
            luks = {
              end = "-${cfg.swapSize}";
              content = luks "cryptroot" btrfs;
            };
            cryptswap = {
              size = cfg.swapSize;
              content = luks "cryptswap" swap;
            };
          }
        else
          {
            root = {
              end = "-${cfg.swapSize}";
              content = btrfs;
            };
            swap = {
              size = cfg.swapSize;
              content = swap;
            };
          };
    in
    {
      options.diskoCfg = {
        device = lib.mkOption {
          type = lib.types.str;
          description = "Target disk, ideally a stable /dev/disk/by-id path.";
        };
        swapSize = lib.mkOption {
          type = lib.types.str;
          description = "Swap partition size (e.g. \"26G\"). Use RAM + 2GB if hibernating.";
        };
        encrypt = lib.mkOption {
          type = lib.types.bool;
          default = true; # secure by default -> hosts opt out
          description = "Wrap root + swap in LUKS. Off = plain partitions, no boot passphrase.";
        };
      };

      config = {
        fileSystems."/nix".neededForBoot = true;
        fileSystems."/persist".neededForBoot = true;
        # otherwise no boot since we need the store and the age key :O

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
              // dataPartitions;
            };
          };

          nodev."/" = {
            fsType = "tmpfs";
            # root dir is just a fs that lives in RAM, anything I want persisted is stored on disk but this is opt in not opt out
            mountOptions = [
              "size=4G"
              # can be experimented with, 4G is just what I landed on in my testing
              "mode=755"
            ];
          };
        };
      };
    };
}
