{ pkgs, ... }:
let
  hideDesktopEntries =
    names:
    builtins.listToAttrs (
      map (name: {
        name = "applications/${name}.desktop";
        value.text = "[Desktop Entry]\nHidden=true\n";
      }) names
    );
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
