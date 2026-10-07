{ pkgs, ... }:
{
  _module.args.shadowDesktopEntries =
    packages: names:
    builtins.listToAttrs (
      map (name: {
        name = "applications/${name}.desktop";
        value.source = pkgs.runCommandLocal "${name}-nodisplay.desktop" { } ''
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

  xdg.mimeApps.enable = true;
}
