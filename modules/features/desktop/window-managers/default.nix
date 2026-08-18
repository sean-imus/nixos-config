{ pkgs, ... }:
{
  imports = [
    ./niri
  ];

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
}
