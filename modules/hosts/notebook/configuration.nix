{ inputs, ... }:
let
  monitorOutputs = {
    "eDP-1" = {
      mode = {
        width = 1920;
        height = 1080;
        refresh = 60.0;
      };
      position = {
        x = 0;
        y = 0;
      };
    };
    "Iiyama North America PL2770H 0x0000011F" = {
      mode = {
        width = 1920;
        height = 1080;
        refresh = 144.0;
      };
      position = {
        x = -1920;
        y = 0;
      };
    };
    "Iiyama North America PL2770H 0x00000124" = {
      mode = {
        width = 1920;
        height = 1080;
        refresh = 143.998;
      };
      position = {
        x = -3840;
        y = 0;
      };
      focus-at-startup = true;
    };
    "Iiyama North America PLX2783H 1128255001580" = {
      mode = {
        width = 1920;
        height = 1080;
        refresh = 60.0;
      };
      position = {
        x = -5760;
        y = 0;
      };
    };
    "GIGA-BYTE TECHNOLOGY CO., LTD. M27U 23463B001145" = {
      mode = {
        width = 3840;
        height = 2160;
        refresh = 60.0;
      };
      position = {
        x = 0;
        y = -1440;
      };
      focus-at-startup = true;
    };
  };
in
{
  flake.modules.nixos.notebook =
    { config, ... }:
    {
      imports = with inputs.self.modules.nixos; [
        hostDefault
        disko
        persistence
        qemu
        sean
        niri
        printing
        rdp-work
      ];

      hostCfg = {
        hm.enable = true;
        audio.enable = true;
        niri.enable = true;
        printing.enable = true;
        rdp-work.enable = true;
      };

      home-manager.users.sean = {
        imports = with inputs.self.modules.homeManager; [
          terminal
          browser
          bar
          lockscreen
          discord
          office-suite
          filesharing
          rdp-work
          niri
          neovim
          opencode
        ];

        programs.niri.settings = {
          outputs = monitorOutputs;

          binds = {
            "Mod+T" = {
              action.spawn = "alacritty";
            };
            "Mod+B" = {
              action.spawn = "firefox";
            };
            "Mod+Ctrl+B" = {
              action.spawn = [
                "alacritty"
                "--class"
                "bluetui"
                "-e"
                "bluetui"
              ];
            };
            "Mod+Ctrl+A" = {
              action.spawn = [
                "alacritty"
                "--class"
                "wiremix"
                "-e"
                "wiremix"
                "-v"
                "playback"
              ];
            };
            "Mod+Ctrl+W" = {
              action.spawn = [
                "alacritty"
                "--class"
                "netpala"
                "-e"
                "netpala"
              ];
            };
            "Mod+Shift+Space" = {
              action.spawn = [
                "sh"
                "-c"
                "pkill waybar || true && waybar"
              ];
            };
            "Mod+Ctrl+Space" = {
              action.spawn = [
                "sh"
                "-c"
                "pkill waybar"
              ];
            };
            "Mod+P" = {
              action.spawn = "power-toggle";
            };
            "Mod+Ctrl+Shift+C" = {
              action.spawn = "screencap";
            };
          };
        };
      };

      diskoConfigDevice = "/dev/disk/by-id/nvme-SAMSUNG_MZALQ512HALU-000L2_S4UKNF0R457642";

      networking.hostName = "notebook";

      hardware = {
        enableRedistributableFirmware = true;
        cpu.intel.updateMicrocode = true;
        bluetooth.enable = true;
      };

      boot.initrd.availableKernelModules = [
        "nvme"
        "thunderbolt"
        "xhci_pci"
        "usbhid"
      ];

      boot.kernelModules = [
        "kvm-intel"
        "i915"
      ];

      services.power-profiles-daemon.enable = true;

      environment.shellAliases = {
        rbs = "sudo nixos-rebuild switch --flake .#${config.networking.hostName}";
        rbb = "sudo nixos-rebuild boot --flake .#${config.networking.hostName} && reboot";
      };
    };
}
