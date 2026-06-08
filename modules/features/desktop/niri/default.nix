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

          layout = {
            gaps = 1;
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
              width = 1;
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
              matches = [ { app-id = "^netpala$"; } ];
              open-floating = true;
            }
            {
              matches = [ { app-id = "^localsend_app$"; } ];
              open-floating = true;
            }
          ];
        };
      };
    };
}
