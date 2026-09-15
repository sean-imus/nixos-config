{ pkgs, ... }:
let
  noDisplayDesktopEntries =
    packages: names:
    builtins.listToAttrs (
      map (name: {
        name = "applications/${name}.desktop";
        value.source = pkgs.runCommand "${name}-nodisplay.desktop" { } ''
          for dir in ${builtins.concatStringsSep " " (map (p: "${p}/share/applications") packages)}; do
            if [ -f "$dir/${name}.desktop" ]; then
              sed '/^\[Desktop Entry\]$/a NoDisplay=true' "$dir/${name}.desktop" > $out
              exit 0
            fi
          done
          echo "desktop file ${name}.desktop not found" >&2
          exit 1
        '';
      }) names
    );
in
{
  home.packages = [ pkgs.libreoffice-stable ];

  xdg.dataFile =
    noDisplayDesktopEntries
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
