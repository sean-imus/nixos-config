{ config, pkgs, ... }:
let
  rebuildScript = pkgs.writeShellScript "rebuild-system" ''
    notify() {
      ${pkgs.libnotify}/bin/notify-send --app-name="System rebuild" "$@"
    }

    log="''${XDG_CACHE_HOME:-$HOME/.cache}/nh-os-switch.log"
    export NH_FLAKE="${config.programs.nh.flake}"

    exec 9>/tmp/rebuild-system.lock
    ${pkgs.util-linux}/bin/flock -n 9 || exit 0

    ${pkgs.systemd}/bin/systemctl --user start polkit-soteria.service 2>/dev/null || true

    id=$(notify --print-id --expire-time=0 "Rebuilding system" "nh os switch is running in the background" 2>/dev/null || true)

    if ${pkgs.nh}/bin/nh os switch --elevation-strategy /run/current-system/sw/bin/run0 >"$log" 2>&1; then
      notify ''${id:+--replace-id=$id} "Rebuild finished" "The system configuration was applied."
    else
      notify --urgency=critical ''${id:+--replace-id=$id} "Rebuild failed" "See $log"
    fi
  '';
in
{
  wayland.windowManager.niri.settings.binds."Mod+U" = {
    spawn = [ "${rebuildScript}" ];
  };
}
