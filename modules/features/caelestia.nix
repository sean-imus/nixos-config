{ inputs, pkgs, ... }:
{
  imports = [
    inputs.caelestia-shell.homeManagerModules.default
  ];

  xdg.configFile = {
    "caelestia/hypr-vars.lua".text = ''
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
    "caelestia/hypr-user.conf".text = ''
      monitor = eDP-1, preferred, 0x0, 1
      monitor = Iiyama North America PL2770H 0x0000011F, 1920x1080@144, -1920x0, 1
      monitor = Iiyama North America PL2770H 0x00000124, 1920x1080@144, -3840x0, 1
      monitor = GIGA-BYTE TECHNOLOGY CO., LTD. M27U 23463B001145, 3840x2160@60, 0x-1234, 1.75

      input {
        kb_layout = de
        kb_options = caps:escape
        numlock_by_default = true
        follow_mouse = 1
        warp_mouse_to_focus = true
        touchpad {
          natural_scroll = true
          tap_to_click = true
          drag_lock = true
          disable_while_typing = true
        }
      }
    '';
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
