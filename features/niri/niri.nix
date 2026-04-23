{ pkgs, ... }:

{
  nixosModule = {};

  homeManagerModule = {
    # Niri Config File
    home.file.".config/niri/config.kdl" = {
      source = ./niri-config.kdl;
      force = true;
    };

    # Waybar
    programs.waybar = {
      enable = true;
    };

    # Waybar Config
    xdg.configFile."waybar/config.jsonc".source = ./waybar-config.jsonc;
    xdg.configFile."waybar/style.css".source = ./waybar-style.css;

    # Application Launcher
    programs.fuzzel = {
      enable = true;
    };

    # Lock Screen
    programs.swaylock = {
      enable = true;
    };

    # Notification Daemon
    services.mako = {
      enable = true;
    };

    # Audio Button Support
    services.playerctld = {
      enable = true;
    };

    # Install Depends
    home.packages = with pkgs; [
      xwayland-satellite # Xwayland support
      awww # wallpaper daemon
      font-awesome # waybar font
    ];
  };
}
