{ pkgs, ... }:
{
  wayland.windowManager.niri.extraConfig = ''
    spawn-at-startup "${pkgs.swaybg}/bin/swaybg" "-i" "${../../assets/13977451.png}" "-m" "fill"
  '';
}
