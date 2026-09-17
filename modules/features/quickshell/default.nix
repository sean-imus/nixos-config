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
  # Personal Quickshell shell: one process owning the bar, notifications,
  # polkit agent and OSD. New surfaces grow here; see MEMORY.md for the plan.
  programs.quickshell = {
    enable = true;
    systemd.enable = false;
    configs.qs-shell = qml;
  };

  home.packages = [ pkgs.libnotify ];

  wayland.windowManager.niri.settings = {
    _children = [
      {
        "spawn-at-startup"._args = [
          "quickshell"
          "-c"
          "qs-shell"
          "-n"
        ];
      }
      {
        layer-rule._children = [
          {
            match._props.namespace = "^qs-shell-notifs$";
            "geometry-corner-radius" = 16;
            background-effect.blur = true;
          }
        ];
      }
      {
        layer-rule._children = [
          {
            match._props.namespace = "^qs-shell-polkit$";
            "geometry-corner-radius" = 12;
            background-effect.blur = true;
          }
        ];
      }
    ];

    binds = {
      "Mod+Shift+D".spawn = [
        "quickshell"
        "-c"
        "qs-shell"
        "ipc"
        "call"
        "notifs"
        "toggleDnd"
      ];
      "Mod+Shift+N".spawn = [
        "quickshell"
        "-c"
        "qs-shell"
        "ipc"
        "call"
        "notifs"
        "clear"
      ];
      "Mod+P" = {
        _props.repeat = false;
        spawn = [
          "quickshell"
          "-c"
          "qs-shell"
          "ipc"
          "call"
          "powerprofiles"
          "cycle"
        ];
      };
    };
  };
}
