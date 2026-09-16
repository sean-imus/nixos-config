{ lib, pkgs, ... }:
let
  theme = import ../../lib/theme.nix;

  # QML uses a slightly different name for the UI font than the rest of the repo.
  themeQml = pkgs.writeText "Theme.qml" ''
    pragma Singleton

    import QtQuick
    import Quickshell

    Singleton {
        readonly property string fontFamily: "${theme.fontFamily}";
    ${lib.concatStringsSep "\n" (
      lib.mapAttrsToList (name: value: ''readonly property color ${name}: "#${value}";'') (
        lib.filterAttrs (name: value: builtins.isString value && name != "fontFamily") theme
      )
    )}
    }
  '';

  qml = pkgs.runCommand "qs-shell-qml" { } ''
    mkdir -p $out/config
    cp -r ${./qml}/. $out/
    chmod -R u+w $out
    cp ${themeQml} $out/config/Theme.qml
  '';
in
{
  # Personal Quickshell shell, built from scratch. Step 1: a clock bar.
  # New surfaces (panels, OSD, lock) grow here; see MEMORY.md for the plan.
  programs.quickshell = {
    enable = true;
    configs.qs-shell = qml;
  };
}
