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
    ./wallpaper.nix
  ];
}
