{ pkgs, ... }:
let
  hideDesktopEntries = import ../../lib/desktop-hide.nix;
in
{
  home.packages = [ pkgs.libreoffice-fresh ];

  xdg.dataFile = hideDesktopEntries [
    "base"
    "draw"
    "impress"
    "math"
    "startcenter"
    "xsltfilter"
  ];
}
