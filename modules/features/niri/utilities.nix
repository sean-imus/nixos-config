{ pkgs, theme, ... }:
let
  colors = theme;
  hideDesktopEntries =
    names:
    builtins.listToAttrs (
      map (name: {
        name = "applications/${name}.desktop";
        value.text = "[Desktop Entry]\nHidden=true\n";
      }) names
    );
in
{
  home.packages = [ pkgs.swaybg ];

  wayland.windowManager.niri.settings = {
    _children = [
      {
        "spawn-at-startup"._args = [ "waybar" ];
      }
      {
        "spawn-at-startup"._args = [
          "swaybg"
          "-i"
          "${../../../assets/wallpaper.png}"
          "-m"
          "fill"
        ];
      }
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
      gaps = 8;
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
        "active-color" = "#${colors.green}";
        "inactive-color" = "#00000000";
      };
      shadow.off = { };
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

  xdg.dataFile = hideDesktopEntries [
    "cups"
    "btop"
    "nvim"
    "mpv"
    "foot"
    "footclient"
    "foot-server"
  ];
}
