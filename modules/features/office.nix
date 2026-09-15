{ pkgs, ... }:
let
  shadowDesktopEntries = import ../lib/desktop-entries.nix { inherit pkgs; };
in
{
  home.packages = [ pkgs.libreoffice-stable ];

  xdg.dataFile =
    shadowDesktopEntries
      [ pkgs.libreoffice-stable ]
      [
        "base"
        "draw"
        "impress"
        "math"
        "startcenter"
        "xsltfilter"
      ];
}
