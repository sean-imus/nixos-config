{ config, pkgs, ... }:
let
  applySystem = pkgs.writeShellScript "apply-system" ''
    set -euo pipefail

    system="$1"

    "$system/bin/switch-to-configuration" test
    ${pkgs.nix}/bin/nix build --no-link --profile /nix/var/nix/profiles/system "$system"
    "$system/bin/switch-to-configuration" boot
  '';

  rebuildScript = pkgs.writeShellScript "rebuild-system" ''
    notify() {
      ${pkgs.libnotify}/bin/notify-send --app-name="System rebuild" "$@"
    }

    log="''${XDG_CACHE_HOME:-$HOME/.cache}/nh-os-switch.log"
    result="''${XDG_RUNTIME_DIR:-/tmp}/rebuild-system-result"
    export NH_FLAKE="${config.programs.nh.flake}"

    exec 9>/tmp/rebuild-system.lock
    ${pkgs.util-linux}/bin/flock -n 9 || exit 0

    id=$(notify --print-id --expire-time=0 "Rebuilding system" "Building the new configuration in the background" 2>/dev/null || true)

    if ! ${pkgs.nh}/bin/nh os build --out-link "$result" >"$log" 2>&1; then
      notify --urgency=critical ''${id:+--replace-id=$id} "Rebuild failed" "Build failed, see $log"
      exit 1
    fi

    if /run/current-system/sw/bin/run0 ${applySystem} "$(readlink -f "$result")" >>"$log" 2>&1; then
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
