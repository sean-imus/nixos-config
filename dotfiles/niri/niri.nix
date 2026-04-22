{ ... }:

{
  # Niri Config File
  home.file.".config/niri/config.kdl".source = ./niri-config.kdl;
  home.file.".config/niri/config.kdl".force = true;

  # Waybar
  programs.waybar = {
    enable = true;
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
  services.awww = {
    enable = true;
  };
}
