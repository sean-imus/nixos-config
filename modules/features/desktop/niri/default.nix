{ inputs, ... }:
{
  flake-file.inputs = {
    niri = {
      url = "github:sodiboo/niri-flake";
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
            gaps = 2;
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
              enable = false;
            };
          };

          hotkey-overlay.skip-at-startup = true;
          prefer-no-csd = true;
          screenshot-path = "~/Screenshots/%Y-%m-%d %H-%M-%S.png";

          clipboard.disable-primary = true;

          animations = {
            enable = false;
          };

          window-rules = [
            {
              matches = [ { app-id = "^netpala$"; } ];
              open-floating = true;
            }
          ];
        };
      };
    };
}
