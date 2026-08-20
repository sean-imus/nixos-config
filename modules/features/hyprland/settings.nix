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
    "hypr/scheme/current.lua" = {
      source = "${inputs.caelestia-dots}/hypr/scheme/default.lua";
      force = true;
    };
    "hypr/hyprland/input.lua" = {
      text = ''
        local vars = require("variables")

        -- Monitor configuration
        hl.monitor({ output = "eDP-1", mode = "preferred", position = "0x0", scale = 1 })
        hl.monitor({ output = "Iiyama North America PL2770H 0x0000011F", mode = "1920x1080@144", position = "-1920x0", scale = 1 })
        hl.monitor({ output = "Iiyama North America PL2770H 0x00000124", mode = "1920x1080@144", position = "-3840x0", scale = 1 })
        hl.monitor({ output = "GIGA-BYTE TECHNOLOGY CO., LTD. M27U 23463B001145", mode = "3840x2160@60", position = "0x-1234", scale = 1.75 })

        hl.config({
            input = {
                kb_layout          = "de",
                kb_options         = "caps:escape",
                numlock_by_default = true,
                repeat_delay       = 250,
                repeat_rate        = 35,
                focus_on_close     = 1,
                follow_mouse       = 1,
                warp_mouse_to_focus = true,

                touchpad           = {
                    natural_scroll       = true,
                    disable_while_typing = vars.touchpadDisableTyping,
                    scroll_factor        = vars.touchpadScrollFactor,
                    tap_to_click         = true,
                    drag_lock            = true,
                },
            },

            binds = {
                scroll_event_delay = 0,
            },

            cursor = {
                hotspot_padding = 1,
            },
        })
      '';
      force = true;
    };
  };
}
