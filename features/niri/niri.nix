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
