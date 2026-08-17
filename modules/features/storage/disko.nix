{ lib, config, ... }:
let
  cfg = config.diskoCfg;

  swapSize = "${toString (cfg.memorySize + 2)}G";

  btrfs = {
    type = "btrfs";
    extraArgs = [ "-f" ];
    mountpoint = "/";
    mountOptions = [
      "compress=zstd"
      "noatime"
    ];
  };

  swap = {
    type = "swap";
    resumeDevice = false;
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
    memorySize = lib.mkOption {
      type = lib.types.int;
      description = "RAM size in GB. Swap partition is set to this + 2 GB.";
    };
  };

  config = {
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
