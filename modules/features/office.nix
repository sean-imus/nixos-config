{ pkgs, shadowDesktopEntries, ... }:
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
