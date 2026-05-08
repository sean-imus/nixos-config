{ pkgs, config, ... }:

let
  niriPath = "${config.home.homeDirectory}/nixos-config/features/niri/niri-config.kdl";
  waybarConfigPath = "${config.home.homeDirectory}/nixos-config/features/niri/waybar-config.jsonc";
  waybarStylePath = "${config.home.homeDirectory}/nixos-config/features/niri/waybar-style.css";
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
        default-timeout = 5000;
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

      (pkgs.writeShellScriptBin "mod-toggle" ''
        KDL="$HOME/.config/niri/vmalias.kdl"
        if [ -f "$KDL" ] && grep -q 'mod-key "Alt"' "$KDL" 2>/dev/null; then
          rm -f "$KDL"
        else
          printf "input {\n    mod-key \"Alt\"\n}\n" > "$KDL"
        fi
      '')
    ];

    home.shellAliases = {
      vmalias = "mod-toggle";
    };

  };
}
