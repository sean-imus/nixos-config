{ pkgs, ... }:
{
  imports = [
    ./niri
    ./driftwm
  ];

  environment.systemPackages = with pkgs; [
    brightnessctl
    grim
    slurp
    swappy
    wl-clipboard
    cliphist
    playerctl
    wlr-randr
    swaynotificationcenter
    xwayland-satellite
    swaybg
    wiremix
    bluetui
    feh
  ];
}
