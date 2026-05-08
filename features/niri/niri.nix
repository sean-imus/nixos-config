{ pkgs, config, ... }:

let
  niriPath = "${config.home.homeDirectory}/nixos-config/features/niri/niri-config.kdl";
  waybarDir = "${config.home.homeDirectory}/nixos-config/features/niri/waybar";
  waybarConfigPath = "${waybarDir}/config.jsonc";
  waybarStylePath = "${waybarDir}/style.css";
  cavaWaybarConfigPath = "${waybarDir}/cava-waybar-glsl.conf";
  cavaShaderDir = "${waybarDir}/cava-shaders";
in

{
  nixosModule = { };

  homeManagerModule = {
    # Niri Config File
    xdg.configFile."niri/config.kdl" = {
      source = config.lib.file.mkOutOfStoreSymlink niriPath;
      force = true;
    };

    # Waybar Config
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

    # Notification Daemon
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

    # Keyboard Audio Button Daemon
    services.playerctld = {
      enable = true;
    };

    # Install Dependencies
    home.packages = with pkgs; [
      xwayland-satellite # XWayland Support
      awww # Wallpaper Daemon
      font-awesome # Waybar Font
      wiremix # Audio TUI
      swaylock # Lockscreen
      fuzzel # Application Launcher
      waybar # Bar
      bluetui # Bluetooth TUI
      brightnessctl # Laptop Monitor Brightness
      cava # Terminal Music Visualizer
      mpv # Video Player
      wf-recorder # Screen Recorder
      slurp # Region Selector

      (pkgs.writeShellScriptBin "mod-toggle" ''
        KDL="$HOME/.config/niri/vmalias.kdl"
        if [ -f "$KDL" ] && grep -q 'mod-key "Alt"' "$KDL" 2>/dev/null; then
          rm -f "$KDL"
        else
          printf "input {\n    mod-key \"Alt\"\n}\n" > "$KDL"
        fi
      '')
      libnotify
      (pkgs.writeShellScriptBin "wiremix-term" ''
        alacritty --class wiremix -e wiremix
      '')
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
        if pgrep -x wf-recorder > /dev/null; then
          pkill -x wf-recorder
          sleep 0.2
          pkill -RTMIN+8 waybar
          exit 0
        fi
        geometry=$(slurp)
        if [ $? -ne 0 ]; then
          pkill -RTMIN+8 waybar
          exit 1
        fi
        wf-recorder -g "$geometry" -r 30 -c libx264 -f "$HOME/Videos/screenrecord-$(date +%Y%m%d-%H%M%S).mp4" &
        pkill -RTMIN+8 waybar
        wait
      '')
    ];

    home.shellAliases = {
      vmalias = "mod-toggle";
    };

  };
}
