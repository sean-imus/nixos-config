{ inputs, ... }:
{
  flake.modules.nixos.gaming-notebook =
    { config, ... }:
    {
      imports = with inputs.self.modules.nixos; [
        hostDefault
        disko
        persistence
        sean
        niri
      ];

      hostCfg = {
        hm.enable = true;
        audio.enable = true;
        niri.enable = true;
      };

      home-manager.users.sean = {
        imports = with inputs.self.modules.homeManager; [
          terminal
          browser
          bar
          lockscreen
          discord
          office-suite
          neovim
          opencode
        ];

        programs.niri.settings = {
          outputs = { };

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

      diskoConfigDevice = "/dev/disk/by-id/nvme-FIXME-ME";

      networking.hostName = "gaming-notebook";

      nixpkgs.config.allowUnfree = true;

      hardware = {
        enableRedistributableFirmware = true;
        cpu.intel.updateMicrocode = true;
        bluetooth.enable = true;
        graphics.enable = true;
        nvidia = {
          modesetting.enable = true;
          nvidiaSettings = true;
          open = false;
        };
      };

      boot.initrd.availableKernelModules = [
        "nvme"
        "xhci_pci"
        "usbhid"
      ];

      boot.kernelModules = [
        "kvm-intel"
        "i915"
        "nvidia"
        "nvidia_drm"
        "nvidia_modeset"
        "nvidia_uvm"
      ];

      environment.shellAliases = {
        rbs = "sudo nixos-rebuild switch --flake .#${config.networking.hostName}";
        rbb = "sudo nixos-rebuild boot --flake .#${config.networking.hostName} && reboot";
      };
    };
}
