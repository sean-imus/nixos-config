{ lib, config, ... }:
let
  cfg = config.diskoCfg;

  swapSize = if cfg.hibernationSupport then "${toString (cfg.memorySize + 2)}G" else cfg.swapSize;

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
    };
  };

  swap = {
    type = "swap";
    resumeDevice = cfg.hibernationSupport;
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
  options.diskoCfg = {
    device = lib.mkOption {
      type = lib.types.str;
      description = "Disk ID (e.g. nvme-SAMSUNG_MZALQ512HALU-000L2_S4UKNF0R457642)";
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
  };

  config = {
    assertions = [
      {
        assertion = !cfg.hibernationSupport || cfg.memorySize != null;
        message = "diskoCfg.memorySize must be set on hibernating hosts";
      }
    ];

    fileSystems."/nix".neededForBoot = true;

    disko.devices = {
      disk.main = {
        type = "disk";
        device = "/dev/disk/by-id/${cfg.device}";
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
    };
  };
}
