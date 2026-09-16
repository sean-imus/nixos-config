{
  lib,
  pkgs,
  ...
}:
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

  qml = pkgs.runCommand "caelestia-notifs-qml" { } ''
    mkdir -p $out
    cp -r ${./qml}/. $out/
    chmod -R u+w $out
    cp ${themeQml} $out/config/Theme.qml
  '';

  ipc = [
    "quickshell"
    "-c"
    "caelestia-notifs"
    "ipc"
    "call"
    "notifs"
  ];
in
{
  programs.quickshell = {
    enable = true;
    systemd.enable = false;
    configs.caelestia-notifs = qml;
  };

  home.packages = [
    pkgs.libnotify
    pkgs.material-symbols
  ];

  wayland.windowManager.niri.settings = {
    _children = [
      {
        "spawn-at-startup"._args = [
          "quickshell"
          "-c"
          "caelestia-notifs"
          "-n"
        ];
      }
      {
        layer-rule._children = [
          {
            match._props.namespace = "^caelestia-notifs$";
            "geometry-corner-radius" = 16;
            background-effect.blur = true;
          }
        ];
      }
    ];

    binds = {
      "Mod+Shift+D".spawn = ipc ++ [ "toggleDnd" ];
      "Mod+Shift+N".spawn = ipc ++ [ "clear" ];
    };
  };
}
