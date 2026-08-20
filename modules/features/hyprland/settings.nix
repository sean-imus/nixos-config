{ inputs, ... }:
{
  wayland.windowManager.hyprland = {
    enable = false;
  };

  xdg.configFile = {
    "hypr/hyprland" = {
      source = "${inputs.caelestia-dots}/hypr/hyprland";
      recursive = true;
    };
    "hypr/scheme" = {
      source = "${inputs.caelestia-dots}/hypr/scheme";
      recursive = true;
    };
    "hypr/utils" = {
      source = "${inputs.caelestia-dots}/hypr/utils";
      recursive = true;
    };
    "hypr/hyprland.lua".source = "${inputs.caelestia-dots}/hypr/hyprland.lua";
    "hypr/variables.lua".source = "${inputs.caelestia-dots}/hypr/variables.lua";
    "hypr/scheme/current.lua" = {
      source = "${inputs.caelestia-dots}/hypr/scheme/default.lua";
      force = true;
    };
    "hypr/hyprland/execs.lua" = {
      text = ''
        local vars = require("variables")

        hl.on("hyprland.start", function()
            -- Clipboard history
            hl.exec_cmd("wl-paste --type text --watch cliphist store")
            hl.exec_cmd("wl-paste --type image --watch cliphist store")

            -- Start shell
            hl.exec_cmd("caelestia shell -d")
        end)
      '';
      force = true;
    };
  };
}
