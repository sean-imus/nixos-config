{ pkgs, ... }:
{
  imports = [
    ./niri
    ./driftwm
  ];

  environment.systemPackages = with pkgs; [
    brightnessctl
    wl-clipboard
    cliphist
    playerctl
    xwayland-satellite
    swaybg
    wiremix
    bluetui
    feh
  ];
}
