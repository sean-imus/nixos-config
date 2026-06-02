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
            {
              argv = [
                "wl-paste"
                "--watch"
                "cliphist"
                "store"
              ];
            }
            {
              argv = [
                "wl-paste"
                "--type"
                "image/png"
                "--watch"
                "cliphist"
                "store"
              ];
            }
          ];

          hotkey-overlay.skip-at-startup = true;
          prefer-no-csd = true;
          screenshot-path = "~/Screenshots/%Y-%m-%d %H-%M-%S.png";

          clipboard.disable-primary = true;

          animations.enable = false;

          window-rules = [
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
