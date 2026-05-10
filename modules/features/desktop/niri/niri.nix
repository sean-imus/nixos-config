{ ... }:
{
  flake.modules.nixos.niri =
    { ... }:
    {
      nixpkgs.overlays = [
        (final: prev: {
          waybar = (prev.waybar.override { cavaSupport = true; }).overrideAttrs (oa: {
            buildInputs = (oa.buildInputs or [ ]) ++ [ prev.libepoxy ];
            patches = (oa.patches or [ ]) ++ [ ../waybar/cava-glsl-alpha.patch ];
          });
        })
      ];
    };

  flake.modules.homeManager.niri =
    { pkgs, config, ... }:
    let
      flakePath = config.home.homeDirectory + "/nixos-config";
      niriPath = "${flakePath}/modules/features/desktop/niri/niri-config.kdl";
      waybarDir = "${flakePath}/modules/features/desktop/waybar";
      waybarConfigPath = "${waybarDir}/config.jsonc";
      waybarStylePath = "${waybarDir}/style.css";
      cavaWaybarConfigPath = "${waybarDir}/cava-waybar-glsl.conf";
      cavaShaderDir = "${waybarDir}/cava-shaders";
    in
    {
      xdg.configFile."niri/config.kdl" = {
        source = config.lib.file.mkOutOfStoreSymlink niriPath;
        force = true;
      };

      xdg.configFile."waybar/config.jsonc" = {
        source = config.lib.file.mkOutOfStoreSymlink waybarConfigPath;
        force = true;
      };
      xdg.configFile."waybar/style.css" = {
        source = config.lib.file.mkOutOfStoreSymlink waybarStylePath;
        force = true;
      };
      xdg.configFile."cava/waybar-glsl.conf" = {
        source = config.lib.file.mkOutOfStoreSymlink cavaWaybarConfigPath;
        force = true;
      };
      xdg.configFile."cava/shaders/pass_through.vert" = {
        source = config.lib.file.mkOutOfStoreSymlink "${cavaShaderDir}/pass_through.vert";
        force = true;
      };
      xdg.configFile."cava/shaders/bar_spectrum.frag" = {
        source = config.lib.file.mkOutOfStoreSymlink "${cavaShaderDir}/bar_spectrum.frag";
        force = true;
      };

      services.mako = {
        enable = true;
        settings = {
          anchor = "top-right";
          background-color = "#00000088";
          text-color = "#ffffff";
          border-color = "#437306";
          border-radius = 12;
          border-size = 2;
          font = "Sans 11";
          height = 100;
          width = 400;
          margin = "15";
          padding = "5,15";
          max-visible = 5;
        };
      };

      services.playerctld = {
        enable = true;
      };

      home.packages = with pkgs; [
        xwayland-satellite
        awww
        font-awesome
        wiremix
        swaylock
        fuzzel
        waybar
        bluetui
        brightnessctl
        cava
        mpv
        wf-recorder
        slurp

        (pkgs.writeShellScriptBin "mod-toggle" ''
          KDL="$HOME/.config/niri/vmalias.kdl"
          if [ -f "$KDL" ] && grep -q 'mod-key "Alt"' "$KDL" 2>/dev/null; then
            rm -f "$KDL"
          else
            printf "input {\n    mod-key \"Alt\"\n}\n" > "$KDL"
          fi
        '')
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

      home.shellAliases = {
        vmalias = "mod-toggle";
      };
    };
}
