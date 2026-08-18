{ lib, ... }:
let
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
in
{
  disko.devices = {
    disk.main = {
      type = "disk";
      device = "/dev/disk/by-id/nvme-SAMSUNG_MZALQ512HALU-000L2_S4UKNF0R457642";
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
          luks = {
            end = "-26G";
            content = luks "cryptroot" btrfs;
          };
          cryptswap = {
            size = "26G";
            content = luks "cryptswap" swap;
          };
        };
      };
    };
  };
}
