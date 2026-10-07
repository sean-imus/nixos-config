{ pkgs, ... }:
{
  # Hide an application's launcher entries without disabling them.
  #
  # Some packages ship desktop entries we want available for MIME handling but
  # hidden from launchers (LibreOffice components, extra tools). `Hidden=true`
  # removes the entry from the desktop database entirely, which breaks
  # `xdg-open`/MIME launching, so instead copy the real entry and add
  # `NoDisplay=true`.
  #
  # Usage:
  #   { shadowDesktopEntries, pkgs, ... }:
  #   xdg.dataFile = shadowDesktopEntries [ pkgs.libreoffice-stable ] [ "impress" ];
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

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "application/json" = "chromium-privat.desktop";
      "application/pdf" = "chromium-privat.desktop";
      "text/markdown" = "writer.desktop";
      "text/plain" = "writer.desktop";
      "text/x-markdown" = "writer.desktop";

      "image/avif" = "chromium-privat.desktop";
      "image/bmp" = "chromium-privat.desktop";
      "image/gif" = "chromium-privat.desktop";
      "image/jpeg" = "chromium-privat.desktop";
      "image/png" = "chromium-privat.desktop";
      "image/svg+xml" = "chromium-privat.desktop";
      "image/webp" = "chromium-privat.desktop";

      "text/html" = "chromium-privat.desktop";
      "x-scheme-handler/http" = "chromium-privat.desktop";
      "x-scheme-handler/https" = "chromium-privat.desktop";
    };
  };
}
