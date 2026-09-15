{ config, pkgs, ... }:
let
  noDisplayDesktopEntries =
    packages: names:
    builtins.listToAttrs (
      map (name: {
        name = "applications/${name}.desktop";
        value.source = pkgs.runCommand "${name}-nodisplay.desktop" { } ''
          for dir in ${builtins.concatStringsSep " " (map (p: "${p}/share/applications") packages)}; do
            if [ -f "$dir/${name}.desktop" ]; then
              sed '/^\[Desktop Entry\]$/a NoDisplay=true' "$dir/${name}.desktop" > $out
              exit 0
            fi
          done
          echo "desktop file ${name}.desktop not found" >&2
          exit 1
        '';
      }) names
    );
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
        layer-rule._children = [
          {
            match._props.namespace = "^(anyrun|swaync-notification-window|swaync-control-center)$";
            "geometry-corner-radius" = 8;
            background-effect.blur = true;
          }
        ];
      }
      {
        window-rule._children = [
          {
            match._props = {
              app-id = "^(wiremix|bluetui|btop|fluxcast)$";
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

    cursor = {
      "hide-when-typing" = true;
      "xcursor-theme" = "everforest-cursors";
      "xcursor-size" = 24;
    };

    layout = {
      gaps = 6;
      "background-color" = "#000000";
      "center-focused-column" = "on-overflow";
      "always-center-single-column" = { };
      "empty-workspace-above-first" = { };
      "preset-column-widths" = {
        _children = [
          { proportion = 0.25; }
          { proportion = 0.33333; }
          { proportion = 0.5; }
          { proportion = 0.66667; }
          { proportion = 0.75; }
        ];
      };
      "preset-window-heights" = {
        _children = [
          { proportion = 0.25; }
          { proportion = 0.33333; }
          { proportion = 0.5; }
          { proportion = 0.66667; }
          { proportion = 0.75; }
        ];
      };
      "default-column-width" = {
        proportion = 0.5;
      };
      "focus-ring" = {
        width = 2;
        "active-color" = "#a7c080";
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

  services.playerctld.enable = true;

  programs.mpv = {
    enable = true;
    config = {
      hwdec = "vaapi";
      gpu-context = "wayland";
    };
  };

  xdg.dataFile =
    noDisplayDesktopEntries
      [
        config.programs.nixvim.build.packageUnchecked
        pkgs.btop
        pkgs.cups
        pkgs.foot
        pkgs.mpv
      ]
      [
        "cups"
        "btop"
        "nvim"
        "mpv"
        "foot"
        "footclient"
        "foot-server"
      ];
}
