{ inputs, ... }:
{
  flake-file.inputs = {
    #TODO switch back to sodiboo/niri-flake once background-effect merges (PR#1731)
    niri = {
      url = "github:myume/niri-flake/blur";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs";
    };
    netpala = {
      url = "github:joel-sgc/netpala";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.modules.nixos.desktop =
    {
      pkgs,
      ...
    }:
    {
      imports = [
        inputs.niri.nixosModules.niri
        inputs.netpala.nixosModules.default
        #TODO move netpala to _utilities.nix
      ];

      programs.niri.enable = true;
      programs.niri.package = pkgs.niri;
      programs.netpala.enable = true;

      # ScreenCast/Screenshot on niri need the *luminous* backend (not wlr/
      # hyprland). config.niri writes niri-portals.conf (looked up first under
      # XDG_CURRENT_DESKTOP=niri); keys use the impl.portal.* namespace.
      xdg.portal = {
        enable = true;
        extraPortals = [
          pkgs.xdg-desktop-portal-gtk
          pkgs.xdg-desktop-portal-luminous
        ];
        config.niri = {
          default = "gtk";
          "org.freedesktop.impl.portal.ScreenCast" = "luminous";
          "org.freedesktop.impl.portal.Screenshot" = "luminous";
        };
      };
    };

  flake.modules.homeManager.desktop =
    { ... }:
    let
      shaders.window-open = ''
        vec4 expanding_circle(vec3 coords_geo, vec3 size_geo) {
            vec3 coords_tex = niri_geo_to_tex * coords_geo;
            vec4 color = texture2D(niri_tex, coords_tex.st);
            vec2 coords = (coords_geo.xy - vec2(0.5, 0.5)) * size_geo.xy * 2.0;
            coords = coords / length(size_geo.xy);
            float p = niri_clamped_progress;
            if (p * p <= dot(coords, coords))
                color = vec4(0.0);
            return color;
        }
        vec4 open_color(vec3 coords_geo, vec3 size_geo) {
            return expanding_circle(coords_geo, size_geo);
        }
      '';
      shaders.window-close = ''
        vec4 closing_circle(vec3 coords_geo, vec3 size_geo) {
            vec3 coords_tex = niri_geo_to_tex * coords_geo;
            vec4 color = texture2D(niri_tex, coords_tex.st);
            vec2 coords = (coords_geo.xy - vec2(0.5, 0.5)) * size_geo.xy * 2.0;
            coords = coords / length(size_geo.xy);
            float p = 1.0 - niri_clamped_progress;
            if (p * p <= dot(coords, coords))
                color = vec4(0.0);
            return color;
        }
        vec4 close_color(vec3 coords_geo, vec3 size_geo) {
            return closing_circle(coords_geo, size_geo);
        }
      '';
    in
    {
      imports = [
        ./_keybindings.nix
        ./_utilities.nix
      ];

      config = {
        userCfg.extraGroups = [ "video" ];

        programs.niri.settings = {
          binds."Mod+Ctrl+W".action.spawn = [
            "alacritty"
            "--class"
            "netpala"
            "-e"
            "netpala"
          ];
          input = {
            keyboard.numlock = true;
            touchpad = {
              tap = true;
              natural-scroll = true;
              dwt = true;
              drag-lock = true;
            };
            warp-mouse-to-focus.enable = true;
            focus-follows-mouse = {
              enable = true;
              max-scroll-amount = "0%";
            };
          };

          cursor = {
            hide-when-typing = true;
            theme = "everforest-cursors";
            size = 24;
          };

          layout = {
            gaps = 8;
            center-focused-column = "on-overflow";
            always-center-single-column = true;
            empty-workspace-above-first = true;
            preset-column-widths = [
              { proportion = 0.25; }
              { proportion = 0.33333; }
              { proportion = 0.5; }
              { proportion = 0.66667; }
              { proportion = 0.75; }
            ];
            preset-window-heights = [
              { proportion = 0.25; }
              { proportion = 0.33333; }
              { proportion = 0.5; }
              { proportion = 0.66667; }
              { proportion = 0.75; }
            ];
            default-column-width = {
              proportion = 0.5;
            };
            focus-ring = {
              width = 2;
              active.color = "#a7c080";
              inactive.color = "#00000000";
            };
            shadow = {
              enable = true;
              softness = 20.0;
              spread = 3.0;
              offset = {
                x = 0.0;
                y = 4.0;
              };
              color = "#00000055";
            };
          };

          hotkey-overlay.skip-at-startup = true;

          prefer-no-csd = true;

          screenshot-path = "~/Screenshots/%Y-%m-%d %H-%M-%S.png";

          clipboard.disable-primary = true;

          animations = {
            enable = true;
            workspace-switch.kind = {
              spring = {
                damping-ratio = 1.0;
                stiffness = 1000;
                epsilon = 0.0001;
              };
            };
            horizontal-view-movement.kind = {
              spring = {
                damping-ratio = 1.0;
                stiffness = 800;
                epsilon = 0.0001;
              };
            };
            window-movement.kind = {
              spring = {
                damping-ratio = 1.0;
                stiffness = 800;
                epsilon = 0.0001;
              };
            };
            window-open = {
              kind.easing = {
                duration-ms = 250;
                curve = "linear";
              };
              custom-shader = shaders.window-open;
            };
            window-close = {
              kind.easing = {
                duration-ms = 250;
                curve = "linear";
              };
              custom-shader = shaders.window-close;
            };
            window-resize.kind = {
              spring = {
                damping-ratio = 1.0;
                stiffness = 800;
                epsilon = 0.0001;
              };
            };
          };

          window-rules = [
            {
              geometry-corner-radius = {
                top-left = 12.0;
                top-right = 12.0;
                bottom-right = 12.0;
                bottom-left = 12.0;
              };
              clip-to-geometry = true;
            }
            {
              matches = [ { app-id = "^netpala$"; } ];
              open-floating = true;
              opacity = 0.85;
              background-effect.blur = true;
            }
          ];
        };

      };
    };
}
