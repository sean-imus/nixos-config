{ inputs, lib, ... }:
{
  flake-file.inputs = {
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.modules.nixos.disko =
    { config, ... }:
    {
      imports = [ inputs.disko.nixosModules.disko ];

      options.diskoConfigDevice = lib.mkOption {
        type = lib.types.str;
      };

      config = {
        fileSystems."/nix".neededForBoot = true;

        disko.devices = {
          disk.main = {
            type = "disk";
            device = config.diskoConfigDevice;
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
                  content = {
                    type = "luks";
                    name = "cryptroot";
                    settings.allowDiscards = true;

                    content = {
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
                  };
                };

                cryptswap = {
                  size = "26G";
                  content = {
                    type = "luks";
                    name = "cryptswap";
                    settings.allowDiscards = true;
                    content = {
                      type = "swap";
                      resumeDevice = true;
                    };
                  };
                };
              };
            };
          };

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
