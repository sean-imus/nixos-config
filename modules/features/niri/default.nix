{ lib, pkgs, ... }:
{
  programs.niri = {
    enable = true;
    useNautilus = false;
  };

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

  home-manager.sharedModules = [
    ./keybindings.nix
    ./outputs.nix
    ./animations.nix
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
