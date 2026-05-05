{ pkgs, ... }:

{
  nixosModule = { };

  homeManagerModule = {
    # Niri Config File
    home.file.".config/niri/config.kdl" = {
      source = ./niri-config.kdl;
      force = true;
    };

    # Waybar Config
    xdg.configFile."waybar/config.jsonc".source = ./waybar-config.jsonc;
    xdg.configFile."waybar/style.css".source = ./waybar-style.css;

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
    ];

    home.shellAliases = {
      vmalias = ''printf 'input {\n    mod-key "Alt"\n}' > /home/sean/.config/niri/vmalias.kdl'';
    };

  };
}
