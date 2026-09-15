{ pkgs, ... }:
{
  wayland.windowManager.niri.extraConfig = ''
    spawn-at-startup "${pkgs.swaybg}/bin/swaybg" "-i" "${../../assets/everforest.png}" "-m" "fill"
  '';
}
