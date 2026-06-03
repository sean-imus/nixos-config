{ ... }:
{
  flake.modules.homeManager.bar =
    { ... }:
    {
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
            background: #000000;
            color: #ffffff;
          }

          #clock,
          #battery,
          #pulseaudio.sink,
          #pulseaudio.mic {
            padding: 0 6px;
          }

          #battery.charging {
            color: #26a65b;
          }

          #battery.critical:not(.charging) {
            color: #f53c3c;
          }

          #pulseaudio.sink.muted,
          #pulseaudio.mic.source-muted {
            color: #999999;
          }
        '';
      };
    };
}
