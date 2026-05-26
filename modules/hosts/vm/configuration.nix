{ inputs, ... }:
{
  flake.modules.nixos.vm =
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
          vesktop
          libreoffice
        ];

        programs.niri.settings = {
          input.mod-key = "Alt";

          outputs = {
            "Virtual-1" = {
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
          };

          binds = {
            "Alt+T" = {
              action.spawn = "alacritty";
            };
            "Alt+B" = {
              action.spawn = "firefox";
            };
            "Alt+Ctrl+B" = {
              action.spawn = [
                "alacritty"
                "--class"
                "bluetui"
                "-e"
                "bluetui"
              ];
            };
            "Alt+Ctrl+A" = {
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
            "Alt+Ctrl+W" = {
              action.spawn = [
                "alacritty"
                "--class"
                "netpala"
                "-e"
                "netpala"
              ];
            };
            "Alt+Shift+Space" = {
              action.spawn = [
                "sh"
                "-c"
                "pkill waybar || true && waybar"
              ];
            };
            "Alt+Ctrl+Space" = {
              action.spawn = [
                "sh"
                "-c"
                "pkill waybar"
              ];
            };
            "Alt+P" = {
              action.spawn = "power-toggle";
            };
            "Alt+Ctrl+Shift+C" = {
              action.spawn = "screencap";
            };
          };
        };
      };

      diskoConfigDevice = "/dev/disk/by-id/virtio-ROOT";

      networking.hostName = "vm";

      boot.initrd.availableKernelModules = [
        "virtio_blk"
        "virtio_pci"
      ];

      environment.shellAliases = {
        rbs = "sudo nixos-rebuild switch --flake github:sean-imus/nixos-config#${config.networking.hostName}";
        rbb = "sudo nixos-rebuild boot --flake github:sean-imus/nixos-config#${config.networking.hostName} && reboot";
      };
    };
}
