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
        enable = false;
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
      }
      {
        matches = [ { app-id = "^wiremix$"; } ];
        open-floating = true;
      }
      {
        matches = [ { app-id = "^bluetui$"; } ];
        open-floating = true;
      }
    ];

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
  };

  home.packages = with pkgs; [
    xwayland-satellite
    wiremix
    feh
    bluetui
    brightnessctl
    wl-clipboard
    cliphist
    (pkgs.writeShellScriptBin "perf-status" ''
      raw=$(busctl get-property net.hadess.PowerProfiles /net/hadess/PowerProfiles net.hadess.PowerProfiles ActiveProfile)
      current=''${raw#s \"}
      current=''${current%\"}
      case "$current" in
        power-saver) echo '{"text":"PERF low","class":"low","tooltip":"power-saver"}' ;;
        balanced)    echo '{"text":"PERF med","class":"med","tooltip":"balanced"}' ;;
        performance) echo '{"text":"PERF high","class":"high","tooltip":"performance"}' ;;
      esac
    '')
    (pkgs.writeShellScriptBin "power-toggle" ''
      raw=$(busctl get-property net.hadess.PowerProfiles /net/hadess/PowerProfiles net.hadess.PowerProfiles ActiveProfile)
      current=''${raw#s \"}
      current=''${current%\"}
      case "$current" in
        power-saver) next="balanced" ;;
        balanced) next="performance" ;;
        performance) next="power-saver" ;;
      esac
      busctl set-property net.hadess.PowerProfiles /net/hadess/PowerProfiles net.hadess.PowerProfiles ActiveProfile s "$next"
      pkill -RTMIN+9 waybar
    '')
  ];
}
