{
  lib,
  pkgs,
  theme,
  ...
}:
let
  ipc = args: "quickshell -c qs-shell ipc call ${args}";

  themeQml = pkgs.writeText "Theme.qml" ''
    pragma Singleton

    import QtQuick
    import Quickshell

    Singleton {
        readonly property string fontFamily: "${theme.fontFamily}";
        readonly property string symbolFont: "Symbols Nerd Font Mono";
    ${lib.concatStringsSep "\n" (
      lib.mapAttrsToList (name: value: ''readonly property color ${name}: "#${value}";'') theme.palette
    )}
    }
  '';

  qml = pkgs.runCommandLocal "qs-shell-qml" { } ''
    mkdir -p $out/config
    cp -r ${./qml}/. $out/
    chmod -R u+w $out
    cp ${themeQml} $out/config/Theme.qml
  '';

  restartShell = pkgs.writeShellScript "qs-shell-restart" ''
    export PATH=${pkgs.coreutils}/bin:$PATH
    log=''${XDG_CACHE_HOME:-$HOME/.cache}/qs-shell-restart.log
    pattern='^([^ ]*/)?quickshell -c qs-shell'
    ${pkgs.procps}/bin/pkill -f "$pattern" || true
    for _ in $(seq 40); do
      ${pkgs.procps}/bin/pgrep -f "$pattern" >/dev/null || break
      sleep 0.05
    done
    ${pkgs.util-linux}/bin/setsid ${pkgs.quickshell}/bin/quickshell -c qs-shell -n >"$log" 2>&1 &
    pid=$!
    for _ in $(seq 100); do
      ${pkgs.quickshell}/bin/quickshell -c qs-shell ipc show >/dev/null 2>&1 && break
      kill -0 "$pid" 2>/dev/null || exit 1
      sleep 0.05
    done
    ${pkgs.libnotify}/bin/notify-send -a qs-shell -t 1500 "Shell restarted"
  '';
in
{
  programs.quickshell = {
    enable = true;
    configs.qs-shell = qml;
  };

  home.packages = [
    pkgs.libnotify
    pkgs.grim
  ];

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
    ];

    binds = {
      "Mod+Shift+D".spawn-sh = ipc "notifs toggleDnd";
      "Mod+Shift+N".spawn-sh = ipc "notifs clear";
      "Super+Alt+L".spawn-sh = ipc "lock lock";
      "Mod+Shift+R" = {
        _props.repeat = false;
        spawn = "${restartShell}";
      };
      "Mod+P" = {
        _props.repeat = false;
        spawn-sh = ipc "powerprofiles cycle";
      };
    };
  };
}
