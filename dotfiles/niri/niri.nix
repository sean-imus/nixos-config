{ pkgs, ... }:

{
  # Niri Config File
  home.file.".config/niri/config.kdl" = {
    source = ./niri-config.kdl;
    force = true;
  };

  # Waybar
  programs.waybar = {
    enable = true;
  };

  home.file.".config/waybar/config" = {
    source = ./waybar-config.jsonc;
    force = true;
  };

  home.file.".config/waybar/style.css" = {
    source = ./waybar-style.css;
    force = true;
  };

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
}
