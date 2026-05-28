{ inputs, ... }:
{
  flake-file.inputs = {
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    netpala = {
      url = "github:joel-sgc/netpala";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.modules.nixos.niri =
    {
      pkgs,
      ...
    }:
    {
      imports = [
        inputs.niri.nixosModules.niri
        inputs.netpala.nixosModules.default
      ];

      programs.niri.enable = true;
      programs.niri.package = pkgs.niri;
      programs.netpala.enable = true;

      xdg.portal = {
        enable = true;
        extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
        config.common.default = "gtk";
      };
    };

  flake.modules.homeManager.niri =
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
        programs.niri.settings = {
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

          cursor.hide-when-typing = true;

          outputs = {
            "eDP-1" = {
              position = {
                x = 0;
                y = 0;
              };
            };
            "Iiyama North America PL2770H 0x0000011F" = {
              mode = {
                width = 1920;
                height = 1080;
                refresh = 144.0;
              };
              position = {
                x = -1920;
                y = 0;
              };
            };
            "Iiyama North America PL2770H 0x00000124" = {
              mode = {
                width = 1920;
                height = 1080;
                refresh = 143.998;
              };
              position = {
                x = -3840;
                y = 0;
              };
              focus-at-startup = true;
            };
            "Iiyama North America PLX2783H 1128255001580" = {
              mode = {
                width = 1920;
                height = 1080;
                refresh = 60.0;
              };
              position = {
                x = -5760;
                y = 0;
              };
            };
            "GIGA-BYTE TECHNOLOGY CO., LTD. M27U 23463B001145" = {
              mode = {
                width = 3840;
                height = 2160;
                refresh = 60.0;
              };
              scale = 1.75;
              position = {
                x = 0;
                y = -1234;
              };
              focus-at-startup = true;
            };
            "Virtual-1" = {
              mode = {
                width = 1920;
                height = 1080;
                refresh = 60.0;
              };
              position = {
                x = 0;
                y = 0;
              };
            };
          };

          layout = {
            gaps = 6;
            center-focused-column = "never";
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
              active = {
                color = "green";
              };
              inactive = {
                color = "gray";
              };
            };
          };

          spawn-at-startup = [
            { argv = [ "waybar" ]; }
            { argv = [ "wl-paste" "--watch" "cliphist" "store" ]; }
          ];

          hotkey-overlay.skip-at-startup = true;
          prefer-no-csd = true;
          screenshot-path = "~/Screenshots/%Y-%m-%d %H-%M-%S.png";

          clipboard.disable-primary = true;

          animations = {
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
          };

          window-rules = [
            {
              geometry-corner-radius = {
                top-left = 12.0;
                top-right = 12.0;
                bottom-left = 12.0;
                bottom-right = 12.0;
              };
              clip-to-geometry = true;
            }
            {
              matches = [ { app-id = "^Alacritty$"; } ];
              geometry-corner-radius = {
                top-left = 12.0;
                top-right = 12.0;
                bottom-left = 12.0;
                bottom-right = 12.0;
              };
              clip-to-geometry = true;
            }
            {
              matches = [ { app-id = "^wiremix$"; } ];
              open-floating = true;
            }
            {
              matches = [ { app-id = "^bluetui$"; } ];
              open-floating = true;
            }
            {
              matches = [ { app-id = "^btop$"; } ];
              open-floating = true;
            }
            {
              matches = [ { app-id = "^netpala$"; } ];
              open-floating = true;
            }
            {
              matches = [ { app-id = "^localsend_app$"; } ];
              open-floating = true;
            }
          ];

          layer-rules = [
            {
              matches = [ { namespace = "^waybar$"; } ];
            }
            {
              matches = [ { namespace = "^fuzzel$"; } ];
            }
          ];
        };
      };
    };
}
