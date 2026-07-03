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

      # Shared data layout, independent of encryption: btrfs with @nix + @persist
      # subvolumes (zstd, noatime). Both branches below wrap or expose this.
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
        resumeDevice = true; # enables hibernate/resume; harmless where unused
      };

      luks = name: content: {
        type = "luks";
        inherit name;
        settings.allowDiscards = true;
        inherit content;
      };

      # Encryption is the one structural difference between hosts. When on, the
      # data btrfs and swap each sit inside a LUKS container (interactive
      # passphrase at boot). When off (VM), they're plain partitions — no crypto,
      # no boot prompt. The partition attr *keys* differ per branch deliberately:
      # keeping `luks`/`cryptswap` on the encrypted branch preserves the existing
      # notebook's on-disk layout exactly.
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
          default = true; # secure by default; hosts opt out (e.g. the VM)
          description = "Wrap root + swap in LUKS. Off = plain partitions, no boot passphrase.";
        };
      };

      config = {
        # disko generates every fileSystems entry; these two just flag that they
        # must be mounted in the initrd (persisted state + the nix store).
        fileSystems."/nix".neededForBoot = true;
        fileSystems."/persist".neededForBoot = true;

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

          # Ephemeral root: everything not bind-mounted from /persist is wiped on
          # reboot. See persistence.nix for what survives.
          nodev."/" = {
            fsType = "tmpfs";
            mountOptions = [
              "size=4G"
              "mode=755"
            ];
          };
        };
      };
    };
}
