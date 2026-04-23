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

    # Wallpaper Daemon
    home.packages = [ pkgs.awww ];

    # Audio Button Support
    services.playerctld = {
      enable = true;
    };
  };
}