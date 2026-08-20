{ inputs, ... }:
{
  wayland.windowManager.hyprland = {
    enable = false;
  };

  xdg.configFile = {
    "hypr" = {
      source = "${inputs.caelestia-dots}/hypr";
      recursive = true;
    };
    "hypr/scheme/current.lua".source = "${inputs.caelestia-dots}/hypr/scheme/default.lua";
  };
}
