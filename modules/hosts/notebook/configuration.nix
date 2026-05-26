{ inputs, ... }:
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
