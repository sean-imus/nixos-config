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
        // Icon-only font (installed via nerd-fonts.symbols-only in notebook.nix).
        readonly property string symbolFont: "Symbols Nerd Font Mono";
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

  # Restart the whole shell (bar, notifications, polkit agent, lock) in place and
  # confirm with a toast once the new instance answers IPC. Matches on the
  # command line because the wrapped process name is ".quickshell-wrapped".
  restartShell = pkgs.writeShellScript "qs-shell-restart" ''
    export PATH=${pkgs.coreutils}/bin:$PATH
    log=''${XDG_CACHE_HOME:-$HOME/.cache}/qs-shell-restart.log
    ${pkgs.procps}/bin/pkill -f "quickshell -c qs-shell" || true
    for _ in $(seq 40); do
      ${pkgs.procps}/bin/pgrep -f "quickshell -c qs-shell" >/dev/null || break
      sleep 0.05
    done
    ${pkgs.util-linux}/bin/setsid ${pkgs.quickshell}/bin/quickshell -c qs-shell -n >"$log" 2>&1 &
    pid=$!
    for _ in $(seq 100); do
      ${pkgs.quickshell}/bin/quickshell -c qs-shell ipc show >/dev/null 2>&1 && break
      # Died during startup (e.g. a QML error): stop waiting, the log has why.
      kill -0 "$pid" 2>/dev/null || exit 1
      sleep 0.05
    done
    ${pkgs.libnotify}/bin/notify-send -a qs-shell -t 1500 "Shell restarted"
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

  home.packages = [
    pkgs.libnotify
    # Per-output screenshots for the lock screen background.
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
      "Mod+Shift+R" = {
        _props.repeat = false;
        spawn = [ "${restartShell}" ];
      };
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
