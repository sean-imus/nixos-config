{ ... }:
{
  flake.modules.homeManager.desktop =
    { pkgs, config, ... }:
    let
      recordingsDir = "${config.home.homeDirectory}/Recordings";
      screencap = pkgs.writeShellScriptBin "screencap" ''
        pidfile="/tmp/wl-screenrec.pid"
        if [ -f "$pidfile" ] && kill -0 "$(cat "$pidfile")" 2>/dev/null; then
          kill "$(cat "$pidfile")"
          rm -f "$pidfile"
        else
          geometry=$(slurp -o) || exit 0
          audio=$(printf "no\nyes" | fuzzel --dmenu --prompt "Audio? ") || exit 0
          mkdir -p ${recordingsDir}
          outfile="${recordingsDir}/$(date +%Y-%m-%d_%H-%M-%S).mp4"
          if [ "$audio" = "yes" ]; then
            wl-screenrec -g "$geometry" --audio -b 20MB -m 30 --codec hevc -f "$outfile" &
          else
            wl-screenrec -g "$geometry" -b 20MB -m 30 --codec hevc -f "$outfile" &
          fi
          echo $! > "$pidfile"
        fi
      '';
    in
    {
      home.packages = [
        pkgs.wl-screenrec
        pkgs.slurp
        screencap
      ];

      programs.niri.settings.binds."Mod+Ctrl+Shift+C".action.spawn = "screencap";
    };
}
