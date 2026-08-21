{
  wayland.windowManager.niri.settings.animations = {
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
      "custom-shader" = ''
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
      "duration-ms" = 250;
      curve = "linear";
    };
    "window-close" = {
      "custom-shader" = ''
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
}
