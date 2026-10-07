{ pkgs, theme, ... }:
let
  presets._children = map (proportion: { inherit proportion; }) [
    0.25
    0.33333
    0.5
    0.66667
    0.75
  ];
in
{
  wayland.windowManager.niri.settings = {
    animations = {
      "overview-open-close".spring._props = {
        damping-ratio = 0.85;
        stiffness = 700;
        epsilon = 0.0001;
      };
      "window-close" = {
        duration-ms = 200;
        curve = "ease-out-quad";
      };
      "window-open" = {
        duration-ms = 250;
        curve = "ease-out-expo";
      };
      "workspace-switch".spring._props = {
        damping-ratio = 0.9;
        stiffness = 700;
        epsilon = 0.0001;
      };
    };

    _children = [
      {
        "spawn-at-startup"._args = [
          "wl-paste"
          "--watch"
          "cliphist"
          "store"
        ];
      }
      {
        "spawn-at-startup"._args = [
          "wl-paste"
          "--type"
          "image/png"
          "--watch"
          "cliphist"
          "store"
        ];
      }
      {
        "spawn-at-startup"._args = [
          "${pkgs.swaybg}/bin/swaybg"
          "-i"
          "${../../../assets/everforest.png}"
          "-m"
          "fill"
        ];
      }
      {
        window-rule._children = [
          {
            "clip-to-geometry" = true;
            "geometry-corner-radius" = 8;
            opacity = 0.95;
            background-effect.blur = true;
          }
        ];
      }
      {
        window-rule._children = [
          {
            match._props = {
              app-id = "^(wiremix|bluetui|btop)$";
            };
            "open-floating" = true;
          }
        ];
      }
    ];

    input = {
      keyboard.numlock = true;
      touchpad = {
        tap = { };
        "natural-scroll" = { };
        dwt = { };
        "drag-lock" = { };
      };
      "warp-mouse-to-focus" = { };
      "focus-follows-mouse"._props = {
        "max-scroll-amount" = "0%";
      };
    };

    cursor."hide-when-typing" = true;

    layout = {
      gaps = 6;
      "background-color" = "#000000";
      "center-focused-column" = "on-overflow";
      "always-center-single-column" = { };
      "empty-workspace-above-first" = { };
      "preset-column-widths" = presets;
      "preset-window-heights" = presets;
      "focus-ring" = {
        width = 2;
        "active-color" = theme.hex theme.green;
        "inactive-color" = "#00000000";
      };
      shadow = {
        on = { };
        softness = 40;
        spread = 5;
        offset._props = {
          x = 0;
          y = 5;
        };
        color = "#00000064";
      };
    };

    hotkey-overlay."skip-at-startup" = { };

    prefer-no-csd = { };

    screenshot-path = "~/Screenshots/%Y-%m-%d %H-%M-%S.png";

    clipboard."disable-primary" = { };
  };
}
