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
      xwayland-satellite # Xwayland support
      awww # wallpaper daemon
      font-awesome # waybar font
      wiremix # audio TUI
      swaylock # lockscreen
      fuzzel # application launcher
      waybar # bar
      bluetui # bluetooth TUI
    ];

    home.shellAliases = {
      vmalias = ''printf 'input {\n    mod-key "Alt"\n}' > /home/sean/.config/niri/vmalias.kdl'';
    };

  };
}
