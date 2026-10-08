{ theme, ... }:
{
  flake.modules = {
    nixos.niri = {
      programs.niri = {
        enable = true;
        useNautilus = false;
      };

      services.speechd.enable = false;
    };

    homeManager.niri =
      { lib, pkgs, ... }:
      let
        presets._children = map (proportion: { inherit proportion; }) [
          0.25
          0.33333
          0.5
          0.66667
          0.75
        ];

        workspaceBinds = lib.listToAttrs (
          lib.concatMap (
            n:
            let
              key = toString n;
            in
            [
              (lib.nameValuePair "Mod+${key}" { focus-workspace = n; })
              (lib.nameValuePair "Mod+Ctrl+${key}" { move-column-to-workspace = n; })
            ]
          ) (lib.range 1 9)
        );
      in
      {
        programs.fish.interactiveShellInit = ''
          if test -z "$DISPLAY"; and test -z "$WAYLAND_DISPLAY"; and test (tty) = "/dev/tty1"
            exec niri-session
          end
        '';

        wayland.windowManager.niri = {
          enable = true;
          portalPackage = null;
          systemd.enable = false;

          settings = {
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
                  "${pkgs.swaybg}/bin/swaybg"
                  "-i"
                  "${../../assets/everforest.png}"
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

            recent-windows.binds = {
              "Mod+Tab".next-window = { };
              "Mod+Shift+Tab".previous-window = { };
            };

            binds = workspaceBinds // {
              "Mod+O" = {
                _props.repeat = false;
                _props.allow-inhibiting = false;
                toggle-overview = { };
              };
              "Mod+Q".close-window = { };

              "Mod+H".focus-column-left = { };
              "Mod+J".focus-window-or-workspace-down = { };
              "Mod+K".focus-window-or-workspace-up = { };
              "Mod+L".focus-column-right = { };

              "Mod+Shift+H".move-column-left = { };
              "Mod+Shift+J".move-window-down-or-to-workspace-down = { };
              "Mod+Shift+K".move-window-up-or-to-workspace-up = { };
              "Mod+Shift+L".move-column-right = { };

              "Mod+Ctrl+H".focus-monitor-left = { };
              "Mod+Ctrl+J".focus-monitor-down = { };
              "Mod+Ctrl+K".focus-monitor-up = { };
              "Mod+Ctrl+L".focus-monitor-right = { };

              "Mod+Shift+Ctrl+H".move-column-to-monitor-left = { };
              "Mod+Shift+Ctrl+J".move-column-to-monitor-down = { };
              "Mod+Shift+Ctrl+K".move-column-to-monitor-up = { };
              "Mod+Shift+Ctrl+L".move-column-to-monitor-right = { };

              "Mod+WheelScrollDown" = {
                _props.cooldown-ms = 150;
                focus-workspace-down = { };
              };
              "Mod+WheelScrollUp" = {
                _props.cooldown-ms = 150;
                focus-workspace-up = { };
              };
              "Mod+WheelScrollRight".focus-column-right = { };
              "Mod+WheelScrollLeft".focus-column-left = { };
              "Mod+Shift+WheelScrollDown".focus-column-left = { };
              "Mod+Shift+WheelScrollUp".focus-column-right = { };

              "Mod+Comma".consume-or-expel-window-left = { };
              "Mod+Period".consume-or-expel-window-right = { };

              "Mod+F".maximize-column = { };
              "Mod+Shift+F".fullscreen-window = { };
              "Mod+Ctrl+F".maximize-window-to-edges = { };

              "Mod+Minus".set-column-width = "-10%";
              "Mod+Plus".set-column-width = "+10%";
              "Mod+Shift+Minus".set-window-height = "-10%";
              "Mod+Shift+Plus".set-window-height = "+10%";

              "Mod+V".toggle-window-floating = { };
              "Mod+Shift+V".switch-focus-between-floating-and-tiling = { };

              "Mod+C".screenshot = { };
              "Mod+Shift+C".screenshot-window = { };

              "Mod+Escape" = {
                _props.allow-inhibiting = false;
                toggle-keyboard-shortcuts-inhibit = { };
              };

              "Mod+Shift+E".quit = { };
            };
          };
        };
      };
  };
}
