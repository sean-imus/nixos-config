# Hide an application's launcher entries without disabling them.
#
# Some packages ship desktop entries we want available for MIME handling but
# hidden from launchers (LibreOffice components, extra tools). `Hidden=true`
# removes the entry from the desktop database entirely, which breaks
# `xdg-open`/MIME launching, so instead copy the real entry and add
# `NoDisplay=true`.
#
# Usage:
#   shadowDesktopEntries = import ../lib/desktop-entries.nix { inherit pkgs; };
#   xdg.dataFile = shadowDesktopEntries [ pkgs.libreoffice-stable ] [ "impress" ];
{ pkgs }:
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
)
