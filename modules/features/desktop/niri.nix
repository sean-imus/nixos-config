{ inputs, ... }:
{
  flake-file.inputs.niri = {
    url = "github:sodiboo/niri-flake";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.niri =
    { config, lib, ... }:
    {
      imports = [ inputs.niri.nixosModules.niri ];

      options.hostCfg.niri.enable = lib.mkEnableOption "Niri Wayland compositor";

      config = lib.mkIf config.hostCfg.niri.enable {
        programs.niri.enable = true;
      };
    };

  flake.modules.homeManager.niri =
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
              position = {
                x = 0;
                y = -1440;
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
              sh = "awww-daemon & until awww query &>/dev/null; do sleep 0.1; done && awww img ~/.local/share/wallpapers/yuta_green.jpg";
            }
          ];

          hotkey-overlay.skip-at-startup = true;
          prefer-no-csd = true;
          screenshot-path = "~/Screenshots/%Y-%m-%d %H-%M-%S.png";

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

          binds = {
            XF86AudioRaiseVolume = {
              action.spawn = [
                "wpctl"
                "set-volume"
                "@DEFAULT_AUDIO_SINK@"
                "0.1+"
              ];
              allow-when-locked = true;
            };
            XF86AudioLowerVolume = {
              action.spawn = [
                "wpctl"
                "set-volume"
                "@DEFAULT_AUDIO_SINK@"
                "0.1-"
              ];
              allow-when-locked = true;
            };
            XF86AudioMute = {
              action.spawn = [
                "wpctl"
                "set-mute"
                "@DEFAULT_AUDIO_SINK@"
                "toggle"
              ];
              allow-when-locked = true;
            };
            XF86AudioMicMute = {
              action.spawn = [
                "wpctl"
                "set-mute"
                "@DEFAULT_AUDIO_SOURCE@"
                "toggle"
              ];
              allow-when-locked = true;
            };
            XF86AudioPlay = {
              action.spawn = [
                "playerctl"
                "play-pause"
              ];
              allow-when-locked = true;
            };
            XF86AudioStop = {
              action.spawn = [
                "playerctl"
                "stop"
              ];
              allow-when-locked = true;
            };
            XF86AudioPrev = {
              action.spawn = [
                "playerctl"
                "previous"
              ];
              allow-when-locked = true;
            };
            XF86AudioNext = {
              action.spawn = [
                "playerctl"
                "next"
              ];
              allow-when-locked = true;
            };
            XF86MonBrightnessUp = {
              action.spawn = [
                "brightnessctl"
                "--class=backlight"
                "set"
                "+10%"
              ];
              allow-when-locked = true;
            };
            XF86MonBrightnessDown = {
              action.spawn = [
                "brightnessctl"
                "--class=backlight"
                "set"
                "10%-"
              ];
              allow-when-locked = true;
            };

            "Mod+Space" = {
              action.spawn = "fuzzel";
            };
            "Mod+O" = {
              action."toggle-overview" = [ ];
              repeat = false;
            };
            "Mod+Q" = {
              action."close-window" = [ ];
            };

            "Mod+Left" = {
              action."focus-column-left" = [ ];
            };
            "Mod+Down" = {
              action."focus-window-or-workspace-down" = [ ];
            };
            "Mod+Up" = {
              action."focus-window-or-workspace-up" = [ ];
            };
            "Mod+Right" = {
              action."focus-column-right" = [ ];
            };

            "Mod+Ctrl+Left" = {
              action."move-column-left" = [ ];
            };
            "Mod+Ctrl+Down" = {
              action."move-window-down-or-to-workspace-down" = [ ];
            };
            "Mod+Ctrl+Up" = {
              action."move-window-up-or-to-workspace-up" = [ ];
            };
            "Mod+Ctrl+Right" = {
              action."move-column-right" = [ ];
            };

            "Mod+Shift+Left" = {
              action."focus-monitor-left" = [ ];
            };
            "Mod+Shift+Down" = {
              action."focus-monitor-down" = [ ];
            };
            "Mod+Shift+Up" = {
              action."focus-monitor-up" = [ ];
            };
            "Mod+Shift+Right" = {
              action."focus-monitor-right" = [ ];
            };

            "Mod+Shift+Ctrl+Left" = {
              action."move-column-to-monitor-left" = [ ];
            };
            "Mod+Shift+Ctrl+Down" = {
              action."move-column-to-monitor-down" = [ ];
            };
            "Mod+Shift+Ctrl+Up" = {
              action."move-column-to-monitor-up" = [ ];
            };
            "Mod+Shift+Ctrl+Right" = {
              action."move-column-to-monitor-right" = [ ];
            };

            "Mod+WheelScrollDown" = {
              action."focus-workspace-down" = [ ];
              cooldown-ms = 150;
            };
            "Mod+WheelScrollUp" = {
              action."focus-workspace-up" = [ ];
              cooldown-ms = 150;
            };
            "Mod+WheelScrollRight" = {
              action."focus-column-right" = [ ];
            };
            "Mod+WheelScrollLeft" = {
              action."focus-column-left" = [ ];
            };
            "Mod+Shift+WheelScrollDown" = {
              action."focus-column-left" = [ ];
            };
            "Mod+Shift+WheelScrollUp" = {
              action."focus-column-right" = [ ];
            };

            "Mod+1" = {
              action."focus-workspace" = 1;
            };
            "Mod+2" = {
              action."focus-workspace" = 2;
            };
            "Mod+3" = {
              action."focus-workspace" = 3;
            };
            "Mod+4" = {
              action."focus-workspace" = 4;
            };
            "Mod+5" = {
              action."focus-workspace" = 5;
            };
            "Mod+6" = {
              action."focus-workspace" = 6;
            };
            "Mod+7" = {
              action."focus-workspace" = 7;
            };
            "Mod+8" = {
              action."focus-workspace" = 8;
            };
            "Mod+9" = {
              action."focus-workspace" = 9;
            };

            "Mod+Ctrl+1" = {
              action."move-column-to-workspace" = 1;
            };
            "Mod+Ctrl+2" = {
              action."move-column-to-workspace" = 2;
            };
            "Mod+Ctrl+3" = {
              action."move-column-to-workspace" = 3;
            };
            "Mod+Ctrl+4" = {
              action."move-column-to-workspace" = 4;
            };
            "Mod+Ctrl+5" = {
              action."move-column-to-workspace" = 5;
            };
            "Mod+Ctrl+6" = {
              action."move-column-to-workspace" = 6;
            };
            "Mod+Ctrl+7" = {
              action."move-column-to-workspace" = 7;
            };
            "Mod+Ctrl+8" = {
              action."move-column-to-workspace" = 8;
            };
            "Mod+Ctrl+9" = {
              action."move-column-to-workspace" = 9;
            };

            "Mod+Comma" = {
              action."consume-or-expel-window-left" = [ ];
            };
            "Mod+Period" = {
              action."consume-or-expel-window-right" = [ ];
            };

            "Mod+R" = {
              action."switch-preset-column-width" = [ ];
            };
            "Mod+Shift+R" = {
              action."switch-preset-column-width-back" = [ ];
            };
            "Mod+Ctrl+Shift+R" = {
              action."switch-preset-window-height" = [ ];
            };
            "Mod+Ctrl+R" = {
              action."reset-window-height" = [ ];
            };

            "Mod+F" = {
              action."maximize-column" = [ ];
            };
            "Mod+Shift+F" = {
              action."fullscreen-window" = [ ];
            };
            "Mod+Ctrl+F" = {
              action."maximize-window-to-edges" = [ ];
            };

            "Mod+Minus" = {
              action."set-column-width" = "-10%";
            };
            "Mod+Plus" = {
              action."set-column-width" = "+10%";
            };
            "Mod+Shift+Minus" = {
              action."set-window-height" = "-10%";
            };
            "Mod+Shift+Plus" = {
              action."set-window-height" = "+10%";
            };

            "Mod+V" = {
              action."toggle-window-floating" = [ ];
            };
            "Mod+Shift+V" = {
              action."switch-focus-between-floating-and-tiling" = [ ];
            };

            "Mod+C" = {
              action."screenshot" = [ ];
            };
            "Mod+Ctrl+C" = {
              action."screenshot-screen" = [ ];
            };
            "Mod+Alt+C" = {
              action."screenshot-window" = [ ];
            };

            "Mod+Escape" = {
              action."toggle-keyboard-shortcuts-inhibit" = [ ];
              allow-inhibiting = false;
            };

            "Mod+Shift+E" = {
              action."quit" = [ ];
            };
          };
        };

        home.file.".local/share/wallpapers/yuta_green.jpg".source = ../../../assets/yuta_green.jpg;

        programs.fuzzel = {
          enable = true;
          settings = {
            main = {
              dpi-aware = false;
              namespace = "fuzzel";
              icons-enabled = true;
              sort-result = false;
            };
            colors = {
              background = "00000066";
              text = "ffffffff";
              prompt = "ccccccff";
              input = "ffffffff";
              match = "84c906ff";
              selection = "84c90644";
              selection-text = "ffffffff";
              selection-match = "84c906ff";
              border = "84c90655";
            };
            border = {
              width = 2;
              radius = 12;
            };
          };
        };

        services.mako = {
          enable = true;
          settings = {
            anchor = "top-right";
            background-color = "#00000088";
            text-color = "#ffffff";
            border-color = "#437306";
            border-radius = 12;
            border-size = 2;
            font = "Sans 11";
            height = 100;
            width = 400;
            margin = "15";
            padding = "5,15";
            max-visible = 5;
          };
        };

        services.playerctld.enable = true;

        xdg.dataFile = {
          "applications/cups.desktop".text = ''
            [Desktop Entry]
            Hidden=true
          '';
          "applications/nixos-manual.desktop".text = ''
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
          awww
          wiremix
          bluetui
          brightnessctl
          cava
          mpv
          wf-recorder
          slurp
          libnotify
          (pkgs.writeShellScriptBin "power-toggle" ''
            current=$(powerprofilesctl get)
            case "$current" in
              power-saver) next="balanced" ;;
              balanced) next="performance" ;;
              performance) next="power-saver" ;;
            esac
            powerprofilesctl set "$next"
          '')
          (pkgs.writeShellScriptBin "screencap" ''
            STATE=/tmp/waybar-recording
            PIDFILE=/tmp/screencap-pid
            show() { echo '{"text": "●", "class": "recording", "tooltip": "Click to stop"}' > "$STATE"; pkill -RTMIN+8 waybar; }
            hide() { rm -f "$STATE"; pkill -RTMIN+8 waybar; }
            if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
              kill "$(cat "$PIDFILE")"
              sleep 0.2
              hide
              rm -f "$PIDFILE"
              exit 0
            fi
            if pgrep -x slurp > /dev/null; then
              exit 1
            fi
            geometry=$(slurp) || { hide; exit 1; }
            if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
              hide
              exit 1
            fi
            show
            wf-recorder -g "$geometry" -r 30 -c libx264 -f "$HOME/Videos/screenrecord-$(date +%Y%m%d-%H%M%S).mp4" &
            echo $! > "$PIDFILE"
            wait $!
            hide
            rm -f "$PIDFILE"
          '')
        ];
      };
    };
}
