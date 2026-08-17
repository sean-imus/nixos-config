{ inputs, pkgs, ... }:
{
  imports = [ inputs.niri.nixosModules.niri ];

  programs.niri.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-luminous
    ];
    config.niri = {
      default = "gtk";
      "org.freedesktop.impl.portal.ScreenCast" = "luminous";
      "org.freedesktop.impl.portal.Screenshot" = "luminous";
    };
  };

  home-manager.sharedModules = [
    ./keybindings.nix
    ./utilities.nix
    {
      programs.niri.settings.outputs = {
        "eDP-1" = {
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
        "GIGA-BYTE TECHNOLOGY CO., LTD. M27U 23463B001145" = {
          mode = {
            width = 3840;
            height = 2160;
            refresh = 60.0;
          };
          scale = 1.75;
          position = {
            x = 0;
            y = -1234;
          };
          focus-at-startup = true;
        };
      };
    }
  ];
}
