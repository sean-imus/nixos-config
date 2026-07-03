{ ... }:
{
  flake.modules.homeManager.desktop =
    { ... }:
    {
      programs.niri.settings.spawn-at-startup = [ { argv = [ "waybar" ]; } ];

      programs.niri.settings.binds = {
        "Mod+Shift+Space".action.spawn = [
          "sh"
          "-c"
          "pkill waybar || true && waybar"
        ];
        "Mod+Ctrl+Space".action.spawn = [
          "sh"
          "-c"
          "pkill waybar"
        ];
      };

      programs.waybar = {
        enable = true;
        settings = [
          {
            position = "bottom";
            height = 18;
            spacing = 0;
            margin = "0";
            modules-left = [ "clock" ];
            modules-right = [
              "custom/perf"
              "pulseaudio#mic"
              "pulseaudio#sink"
              "battery"
            ];
            clock = {
              format = "{:%H:%M %d.%m.%Y}";
            };
            battery = {
              states = {
                critical = 15;
              };
              format = "BAT {capacity}%";
            };
            "pulseaudio#sink" = {
              format = "VOL {volume}%";
              format-muted = "VOL muted";
              on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
              on-scroll-up = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ -l 1.0";
              on-scroll-down = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
            };
            "pulseaudio#mic" = {
              format = "{format_source}";
              format-source = "MIC {volume}%";
              format-source-muted = "MIC muted";
              on-click = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
              on-scroll-up = "wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 5%+ -l 1.0";
              on-scroll-down = "wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 5%-";
            };
            "custom/perf" = {
              exec = "perf-status";
              signal = 9;
              interval = "once";
              return-type = "json";
              on-click = "power-toggle";
            };
          }
        ];
        style = ''
          * {
            font-family: monospace;
            font-size: 11px;
            padding: 0;
            margin: 0;
          }

          window#waybar {
            background: #2d353b;
            color: #d3c6aa;
          }

          #clock,
          #battery,
          #pulseaudio.sink,
          #pulseaudio.mic,
          #custom-perf {
            padding: 0 6px;
          }

          #battery.charging {
            color: #a7c080;
          }

          #battery.critical:not(.charging) {
            color: #e67e80;
          }

          #pulseaudio.sink.muted,
          #pulseaudio.mic.source-muted {
            color: #7a8478;
          }

          #custom-perf.low {
            color: #a7c080;
          }

          #custom-perf.med {
            color: #dbbc7f;
          }

          #custom-perf.high {
            color: #e67e80;
          }
        '';
      };
    };
}
