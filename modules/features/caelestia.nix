{ inputs, pkgs, ... }:
{
  imports = [
    inputs.caelestia-shell.homeManagerModules.default
  ];

  xdg.configFile = {
    "caelestia/hypr-vars.lua" = {
      text = ''
        return {
          terminal = "kitty",
          browser = "firefox",
          editor = "nvim",
          fileExplorer = "thunar",
          audioSettings = "pwvucontrol",
          cursorTheme = "everforest-cursors",
          cursorSize = 24,
        }
      '';
      force = true;
    };
    "caelestia/hypr-user.lua" = {
      text = ''
        -- Monitor configuration
        hl.monitor({ output = "eDP-1", mode = "preferred", position = "0x0", scale = 1 })
        hl.monitor({ output = "desc:Iiyama North America PL2770H 0x00000124", mode = "1920x1080@144", position = "-1920x0", scale = 1 })
        hl.monitor({ output = "desc:Iiyama North America PL2770H 0x0000011F", mode = "1920x1080@144", position = "-3840x0", scale = 1 })

        -- Input configuration
        hl.config({
            input = {
                kb_layout = "de",
                kb_options = "caps:escape",
                numlock_by_default = true,
                follow_mouse = 1,
                touchpad = {
                    natural_scroll = true,
                    tap_to_click = true,
                    drag_lock = true,
                    disable_while_typing = true,
                },
            },
        })
      '';
      force = true;
    };
    "btop" = {
      source = "${inputs.caelestia-dots}/btop";
      recursive = true;
    };
    "fastfetch" = {
      source = "${inputs.caelestia-dots}/fastfetch";
      recursive = true;
    };
    "starship.toml".source = "${inputs.caelestia-dots}/starship.toml";
  };

  programs.caelestia = {
    enable = true;
    systemd.enable = false;
    settings = {
      general.apps.terminal = [ "kitty" ];
      services.useTwelveHourClock = false;
      bar.statusIcons = [
        {
          id = "lockStatus";
          enabled = true;
        }
        {
          id = "network";
          enabled = true;
        }
        {
          id = "bluetooth";
          enabled = true;
        }
        {
          id = "battery";
          enabled = true;
        }
      ];
    };
    cli.enable = true;
  };
}
