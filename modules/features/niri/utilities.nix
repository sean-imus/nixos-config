{ pkgs, ... }:
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
  home.packages = [ pkgs.swaybg ];

  wayland.windowManager.niri.settings = {
    _children = [
      {
        output._args = [ "eDP-1" ];
        output.position._props = {
          x = 0;
          y = 0;
        };
      }
      {
        output._args = [ "Iiyama North America PL2770H 0x0000011F" ];
        output.mode._args = [ "1920x1080@144.000000" ];
        output.position._props = {
          x = -1920;
          y = 0;
        };
      }
      {
        output._args = [ "Iiyama North America PL2770H 0x00000124" ];
        output.mode._args = [ "1920x1080@143.998000" ];
        output.position._props = {
          x = -3840;
          y = 0;
        };
        output."focus-at-startup" = { };
      }
      {
        output._args = [ "GIGA-BYTE TECHNOLOGY CO., LTD. M27U 23463B001145" ];
        output.mode._args = [ "3840x2160@60.000000" ];
        output.scale = 1.75;
        output.position._props = {
          x = 0;
          y = -1234;
        };
        output."focus-at-startup" = { };
      }
      {
        window-rule._children = [
          {
            match._props = {
              app-id = "^wiremix$";
            };
            "open-floating" = true;
          }
        ];
      }
      {
        window-rule._children = [
          {
            match._props = {
              app-id = "^bluetui$";
            };
            "open-floating" = true;
          }
        ];
      }
      {
        window-rule._children = [
          {
            match._props = {
              app-id = "^btop$";
            };
            "open-floating" = true;
          }
        ];
      }
      {
        window-rule._children = [
          {
            match._props = {
              app-id = "^fluxcast$";
            };
            "open-floating" = true;
          }
        ];
      }
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
        "active-color" = "#a7c080";
        "inactive-color" = "#00000000";
      };
      shadow.off = { };
    };

    hotkey-overlay."skip-at-startup" = { };

    prefer-no-csd = { };

    screenshot-path = "~/Screenshots/%Y-%m-%d %H-%M-%S.png";

    clipboard."disable-primary" = { };

    animations = {
      "workspace-switch" = {
        spring._props = {
          "damping-ratio" = 1.0;
          stiffness = 1000;
          epsilon = 0.0001;
        };
      };
      "horizontal-view-movement" = {
        spring._props = {
          "damping-ratio" = 1.0;
          stiffness = 800;
          epsilon = 0.0001;
        };
      };
      "window-movement" = {
        spring._props = {
          "damping-ratio" = 1.0;
          stiffness = 800;
          epsilon = 0.0001;
        };
      };
      "window-open" = {
        "custom-shader" = shaders.window-open;
        "duration-ms" = 250;
        curve = "linear";
      };
      "window-close" = {
        "custom-shader" = shaders.window-close;
        "duration-ms" = 250;
        curve = "linear";
      };
      "window-resize" = {
        spring._props = {
          "damping-ratio" = 1.0;
          stiffness = 800;
          epsilon = 0.0001;
        };
      };
    };
  };

  services.playerctld.enable = true;

  programs.mpv = {
    enable = true;
    config = {
      hwdec = "vaapi";
      vo = "gpu";
      gpu-context = "wayland";
    };
  };

  xdg.dataFile = {
    "applications/cups.desktop".text = ''
      [Desktop Entry]
      Hidden=true
    '';
    "applications/btop.desktop".text = ''
      [Desktop Entry]
      Hidden=true
    '';
    "applications/nvim.desktop".text = ''
      [Desktop Entry]
      Hidden=true
    '';
    "applications/mpv.desktop".text = ''
      [Desktop Entry]
      Hidden=true
    '';
    "applications/kitty.desktop".text = ''
      [Desktop Entry]
      Hidden=true
    '';
  };
}
