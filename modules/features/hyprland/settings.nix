{ inputs, ... }:
{
  xdg.configFile = {
    "hypr" = {
      source = "${inputs.caelestia-dots}/hypr";
      recursive = true;
    };
    "hypr/scheme/current.lua".source = "${inputs.caelestia-dots}/hypr/scheme/default.lua";
  };

  wayland.windowManager.hyprland.settings = {
    exec-once = [
      "wl-paste --watch cliphist store"
      "wl-paste --type image/png --watch cliphist store"
    ];
  };
}
