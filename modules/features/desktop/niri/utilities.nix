{ pkgs, ... }:
{
  flake.modules.homeManager.niri-utilities =
    { ... }:
    {
      services.playerctld.enable = true;

      xdg.dataFile = {
        "applications/cups.desktop".text = ''
          [Desktop Entry]
          Hidden=true
        '';
        "applications/nixos-manual.desktop".text = ''
          [Desktop Entry]
          Hidden=true
        '';
        "applications/btop.desktop".text = ''
          [Desktop Entry]
          Hidden=true
        '';
        "applications/nvim.desktop".text = ''
          [Desktop Entry]
          Hidden=true
        '';
        "applications/mpv.desktop".text = ''
          [Desktop Entry]
          Hidden=true
        '';
      };

      home.packages = with pkgs; [
        xwayland-satellite
        wiremix
        bluetui
        brightnessctl
        cava
        mpv
        wf-recorder
        slurp
        libnotify
        (pkgs.writeShellScriptBin "power-toggle" ''
          current=$(powerprofilesctl get)
          case "$current" in
            power-saver) next="balanced" ;;
            balanced) next="performance" ;;
            performance) next="power-saver" ;;
          esac
          powerprofilesctl set "$next"
        '')
        (pkgs.writeShellScriptBin "screencap" ''
          STATE=/tmp/waybar-recording
          PIDFILE=/tmp/screencap-pid
          show() { echo '{"text": "●", "class": "recording", "tooltip": "Click to stop"}' > "$STATE"; pkill -RTMIN+8 waybar; }
          hide() { rm -f "$STATE"; pkill -RTMIN+8 waybar; }
          if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
            kill "$(cat "$PIDFILE")"
            sleep 0.2
            hide
            rm -f "$PIDFILE"
            exit 0
          fi
          if pgrep -x slurp > /dev/null; then
            exit 1
          fi
          geometry=$(slurp) || { hide; exit 1; }
          if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
            hide
            exit 1
          fi
          show
          wf-recorder -g "$geometry" -r 30 -c libx264 -f "$HOME/Videos/screenrecord-$(date +%Y%m%d-%H%M%S).mp4" &
          echo $! > "$PIDFILE"
          wait $!
          hide
          rm -f "$PIDFILE"
        '')
      ];
    };
}
