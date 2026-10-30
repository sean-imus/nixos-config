{
  den.default.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      options.xdg.hiddenDesktopEntries = lib.mkOption {
        description = "Desktop entries of a package to hide from launchers.";
        default = { };
        type = lib.types.attrsOf (
          lib.types.submodule {
            options = {
              package = lib.mkOption { type = lib.types.package; };
              names = lib.mkOption { type = lib.types.listOf lib.types.str; };
            };
          }
        );
      };

      config.xdg = {
        dataFile = lib.concatMapAttrs (
          _:
          { package, names }:
          lib.genAttrs' names (
            name:
            lib.nameValuePair "applications/${name}.desktop" {
              source = pkgs.runCommandLocal "${name}-nodisplay.desktop" { } ''
                file=${package}/share/applications/${name}.desktop
                if [ ! -f "$file" ]; then
                  echo "desktop file ${name}.desktop not found" >&2
                  exit 1
                fi
                sed '/^\[Desktop Entry\]$/a NoDisplay=true' "$file" > $out
              '';
            }
          )
        ) config.xdg.hiddenDesktopEntries;

        mimeApps.enable = true;
      };
    };
}
