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
