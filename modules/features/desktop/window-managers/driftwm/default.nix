{ pkgs, ... }:
let
  tomlFormat = pkgs.formats.toml { };
  keybindings = import ./keybindings.nix;
in
{
  config = {
    environment.systemPackages = [ pkgs.driftwm ];

    home-manager.sharedModules = [
      ./utilities.nix
      ({ ... }: {
        xdg.configFile."driftwm/config.toml".source = tomlFormat.generate "driftwm-config.toml" {
          inherit keybindings;

          autostart = [
            "waybar"
            "wl-paste --type image --watch cliphist store"
            "wl-paste --type text --watch cliphist store"
          ];

          window_placement = "center";
          focus_follows_mouse = false;

          input = {
            keyboard = {
              repeat_rate = 25;
              repeat_delay = 200;
            };
            trackpad = {
              tap_to_click = true;
              natural_scroll = true;
              disable_while_typing = true;
            };
          };

          cursor.size = 24;

          navigation = {
            drift = 0.5;
            camera_speed = 0.3;
            nudge_step = 20;
            resize_step = 20;
            pan_step = 100;
          };

          snap = {
            enabled = true;
            gap = 12;
            distance = 24;
          };

          decorations = {
            corner_radius = 10;
            border_width = 0;
            bg_color = "#303030";
            fg_color = "#FFFFFF";
            shadow = true;
          };

          effects = {
            blur_radius = 2;
            blur_strength = 1.1;
            animation_speed = 0.5;
            animation_scale = 0.95;
          };

          background.type = "none";
          xwayland.enabled = true;
          session = {
            restore_windows = false;
            restore_camera = false;
          };
        };
      })
    ];
  };
}
