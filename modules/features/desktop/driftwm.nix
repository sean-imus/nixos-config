{ inputs, ... }:
{
  flake-file.inputs = {
    driftwm = {
      url = "github:malbiruk/driftwm";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.modules.nixos.driftwm = {
    imports = [ inputs.driftwm.nixosModules.default ];
    home-manager.sharedModules = [ inputs.self.modules.homeManager.driftwm ];
    programs.driftwm.enable = true;
  };

  flake.modules.homeManager.driftwm =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.grim ];

      xdg.configFile."driftwm/dense_clouds.glsl".text = ''
        // Dense clouds — stormy sky with gold sun backlighting
        precision highp float;

        varying vec2 v_coords;
        uniform vec2 size;
        uniform vec2 u_camera;
        uniform float u_time;

        float hash(vec2 p) {
            return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
        }

        float noise(vec2 p) {
            vec2 i = floor(p);
            vec2 f = fract(p);
            f = f * f * (3.0 - 2.0 * f);
            return mix(
                mix(hash(i),                  hash(i + vec2(1.0, 0.0)), f.x),
                mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), f.x),
                f.y
            );
        }

        float fbm(vec2 p) {
            float sum = 0.0, amp = 0.5;
            mat2 rot = mat2(0.8, 0.6, -0.6, 0.8);
            for (int i = 0; i < 6; i++) {
                sum += amp * noise(p);
                p = rot * p * 2.0;
                amp *= 0.5;
            }
            return sum;
        }

        void main() {
            vec2 uv = (v_coords * size + u_camera) / 380.0;

            // Slow wind drift
            uv.x += u_time * 0.018;
            uv.y += u_time * 0.007;

            // Domain warp for organic billowing shapes
            float warpX = fbm(uv * 0.7 + vec2(0.0, u_time * 0.012));
            float warpY = fbm(uv * 0.8 + vec2(u_time * 0.010, 5.3));
            vec2 warped = uv + vec2(warpX - 0.5, warpY - 0.5) * 3.0;

            float cloud  = fbm(warped);
            float detail = fbm(warped * 2.5 + vec2(4.1, 2.3));
            float micro  = fbm(warped * 5.0 + vec2(1.7, 6.8));

            // Weighted sum of three frequency bands; micro adds fine edge detail
            float density = clamp(
                smoothstep(0.30, 0.68, cloud)  * 0.72 +
                smoothstep(0.38, 0.74, detail) * 0.22 +
                smoothstep(0.46, 0.80, micro)  * 0.10,
                0.0, 1.0
            );

            // Sun backlighting: glow is strongest on dense cloud edges
            float sunLight = fbm(warped * 1.2 + vec2(0.0, 1.5));
            float sunGlow  = smoothstep(0.55, 0.85, sunLight) * density * 0.55;

            vec3 sky        = vec3(0.157, 0.220, 0.392);
            vec3 stormGray  = vec3(0.157, 0.165, 0.235);
            vec3 midCloud   = vec3(0.322, 0.333, 0.455);
            vec3 brightEdge = vec3(0.639, 0.655, 0.745);
            vec3 sunColor   = vec3(0.980, 0.847, 0.600);

            vec3 col = mix(sky, stormGray, density);
            col = mix(col, midCloud,   smoothstep(0.28, 0.62, density));
            col = mix(col, brightEdge, smoothstep(0.58, 0.84, density) * 0.35);
            col = mix(col, sunColor,   sunGlow * 0.50);

            gl_FragColor = vec4(col, 1.0);
        }
      '';

      xdg.configFile."driftwm/config.toml".text = ''
        mod_key = "super"
        autostart = ["waybar"]

        [input.keyboard]
        layout = "de"

        [cursor]
        theme = "everforest-cursors"
        size = 24
        inactive_opacity = 0.5

        [navigation]
        trackpad_speed = 1.5
        mouse_speed = 1.0
        touch_speed = 1.0
        drift = 0.5
        animation_speed = 0.3
        auto_navigate_on_close = true
        auto_navigate_on_click = false
        nudge_step = 20
        pan_step = 100.0
        anchors = []

        [zoom]
        reset_on_new_window = false

        [decorations]
        bg_color = "#303030"
        fg_color = "#FFFFFF"
        corner_radius = 10
        shadow = true
        title_bar_height = 25
        font = "Adwaita Sans"
        font_size = 11
        font_weight = "medium"
        title_align = "center"
        default_mode = "client"
        border_width = 2
        border_color = "#303030"
        border_color_focused = "#303030"

        [effects]
        blur_radius = 2
        blur_strength = 1.1
        animate_blur_fps = 20

        [background]
        type = "shader"
        path = "~/.config/driftwm/dense_clouds.glsl"
        animate_fps = 0

        [[outputs]]
        name = "eDP-1"
        mode = "preferred"
        position = [0, 0]

        [[outputs]]
        name = "DP-4"
        mode = "1920x1080@144"
        position = [-1920, 0]

        [[outputs]]
        name = "DP-3"
        mode = "1920x1080@144"
        position = [-3840, 0]

        [keybindings]
        "mod+t" = "exec alacritty"
        "mod+d" = "exec fuzzel"
        "mod+q" = "close-window"
        "mod+e" = "toggle-cursor-pan"
        "mod+f" = "toggle-fullscreen"
        "mod+m" = "fit-window"
        "mod+shift+m" = "fit-window-snapped"
        "mod+c" = "center-window"
        "mod+x" = "focus-center"
        "mod+a" = "home-toggle"
        "mod+up" = "center-nearest up"
        "mod+down" = "center-nearest down"
        "mod+left" = "center-nearest left"
        "mod+right" = "center-nearest right"
        "mod+shift+up" = "nudge-window up"
        "mod+shift+down" = "nudge-window down"
        "mod+shift+left" = "nudge-window left"
        "mod+shift+right" = "nudge-window right"
        "mod+ctrl+up" = "pan-viewport up"
        "mod+ctrl+down" = "pan-viewport down"
        "mod+ctrl+left" = "pan-viewport left"
        "mod+ctrl+right" = "pan-viewport right"
        "alt+tab" = "cycle-windows forward"
        "alt+shift+tab" = "cycle-windows backward"
        "mod+equal" = "zoom-in"
        "mod+minus" = "zoom-out"
        "mod+0" = "zoom-reset"
        "mod+z" = "zoom-reset"
        "mod+w" = "zoom-to-fit"
        "mod+shift+w" = "zoom-to-fit-snapped"
        "mod+1" = "go-to-bookmark 1"
        "mod+2" = "go-to-bookmark 2"
        "mod+3" = "go-to-bookmark 3"
        "mod+4" = "go-to-bookmark 4"
        "mod+shift+1" = "set-bookmark 1"
        "mod+shift+2" = "set-bookmark 2"
        "mod+shift+3" = "set-bookmark 3"
        "mod+shift+4" = "set-bookmark 4"
        "mod+alt+up" = "send-to-output up"
        "mod+alt+down" = "send-to-output down"
        "mod+alt+left" = "send-to-output left"
        "mod+alt+right" = "send-to-output right"
        "mod+l" = "spawn swaylock -f -c 000000 -kl"
        "mod+ctrl+shift+q" = "quit"
        "XF86AudioRaiseVolume" = "spawn wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        "XF86AudioLowerVolume" = "spawn wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        "XF86AudioMute" = "spawn wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        "XF86MonBrightnessUp" = "spawn brightnessctl set +5%"
        "XF86MonBrightnessDown" = "spawn brightnessctl set 5%-"
        "XF86AudioPlay" = "spawn playerctl play-pause"
        "XF86AudioPause" = "spawn playerctl play-pause"
        "XF86AudioNext" = "spawn playerctl next"
        "XF86AudioPrev" = "spawn playerctl previous"
        "XF86AudioStop" = "spawn playerctl stop"
        "mod+shift+s" = "spawn grim -g \"$(slurp -d)\" - | wl-copy"
        "mod+shift+ctrl+s" = "spawn grim - | wl-copy"

        [xwayland]
        enabled = true
        path = "xwayland-satellite"

        [output.outline]
        color = "#ffffff"
        thickness = 1
        opacity = 0.5
      '';
    };
}
