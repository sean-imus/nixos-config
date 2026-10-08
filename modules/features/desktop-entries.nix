{
  _module.args.shadowDesktopEntries =
    pkgs: package: names:
    builtins.listToAttrs (
      map (name: {
        name = "applications/${name}.desktop";
        value.source = pkgs.runCommandLocal "${name}-nodisplay.desktop" { } ''
          sed '/^\[Desktop Entry\]$/a NoDisplay=true' ${package}/share/applications/${name}.desktop > $out
        '';
      }) names
    );
}
