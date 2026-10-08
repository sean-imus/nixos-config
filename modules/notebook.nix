{ config, inputs, ... }:
let
  inherit (config.flake.modules) nixos;
in
{
  flake.nixosConfigurations.notebook = inputs.nixpkgs.lib.nixosSystem {
    modules = [ nixos.notebook ];
  };

  flake.modules.nixos.notebook =
    { pkgs, ... }:
    {
      imports = [
        inputs.disko.nixosModules.disko
      ]
      ++ (with nixos; [
        sean

        audio
        bluetooth
        boot
        browser
        claude-code
        clipboard
        debloat
        editor
        file-manager
        filesystems
        firmware
        games
        git
        hardware-dev
        laptop
        launcher
        locale
        lockscreen
        logitech
        media
        network
        niri
        nix
        office
        printing
        quickshell
        rdp-work
        shell
        terminal
        theme
        zram
      ]);

      networking.hostName = "notebook";
      nixpkgs.hostPlatform = "x86_64-linux";
      system.stateVersion = "26.11";

      boot = {
        initrd.availableKernelModules = [
          "nvme"
          "thunderbolt"
          "xhci_pci"
          "usbhid"
        ];
        kernelModules = [ "kvm-intel" ];
        resumeDevice = "/dev/mapper/cryptswap";
      };

      hardware = {
        cpu.intel.updateMicrocode = true;
        graphics.extraPackages = [ pkgs.intel-media-driver ];
      };

      environment.variables.LIBVA_DRIVER_NAME = "iHD";

      services = {
        thermald.enable = true;

        getty = {
          autologinUser = "sean";
          autologinOnce = true;
        };
      };

      networking.networkmanager.ensureProfiles.profiles.rdp-static-eth.connection.interface-name =
        "enp44s0";

      home-manager.sharedModules = [
        {
          wayland.windowManager.niri.settings._children = [
            {
              output = {
                _args = [ "eDP-1" ];
                position._props = {
                  x = 0;
                  y = 0;
                };
              };
            }
            {
              output = {
                _args = [ "iiyama Corporation PL2770H 0x0000011F" ];
                mode._args = [ "1920x1080" ];
                position._props = {
                  x = -1920;
                  y = 0;
                };
              };
            }
            {
              output = {
                _args = [ "iiyama Corporation PL2770H 0x00000124" ];
                mode._args = [ "1920x1080" ];
                position._props = {
                  x = -3840;
                  y = 0;
                };
                "focus-at-startup" = { };
              };
            }
          ];
        }
      ];

      disko.devices.disk.main = {
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
              content = {
                type = "luks";
                name = "cryptroot";
                settings.allowDiscards = true;
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ];
                  mountpoint = "/";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
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
                };
              };
            };
          };
        };
      };
    };
}
