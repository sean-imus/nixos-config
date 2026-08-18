{ lib, pkgs, ... }:
{
  programs.niri.enable = true;

  environment.systemPackages = with pkgs; [
    brightnessctl
    wl-clipboard
    cliphist
    playerctl
    xwayland-satellite
    wiremix
    bluetui
    feh
  ];

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-luminous
    ];
    config.niri = lib.mkForce {
      default = "gtk";
      "org.freedesktop.impl.portal.ScreenCast" = "luminous";
      "org.freedesktop.impl.portal.Screenshot" = "luminous";
    };
  };

  home-manager.sharedModules = [
    ./keybindings.nix
    ./utilities.nix
    {
      wayland.windowManager.niri = {
        enable = true;
        portalPackage = null;
        xwaylandSatellitePackage = null;
        systemd.enable = false;
      };
    }
  ];
}
