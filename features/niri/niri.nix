{ pkgs, config, ... }:

{
  nixosModule = { };

  homeManagerModule = {
    # Niri Config File
    home.file.".config/niri/config.kdl" = {
      source = config.lib.file.mkOutOfStoreSymlink ./niri-config.kdl;
      force = true;
    };

    # Waybar Config
    xdg.configFile."waybar/config.jsonc" = {
      source = config.lib.file.mkOutOfStoreSymlink ./waybar-config.jsonc;
      force = true;
    };
    xdg.configFile."waybar/style.css" = {
      source = config.lib.file.mkOutOfStoreSymlink ./waybar-style.css;
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
    ];

    home.shellAliases = {
      vmalias = ''printf 'input {\n    mod-key "Alt"\n}' > "$HOME/.config/niri/vmalias.kdl"'';
    };

  };
}
