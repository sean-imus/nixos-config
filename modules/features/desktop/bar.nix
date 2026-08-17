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
          "power-profiles-daemon"
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
        "power-profiles-daemon" = {
          format = "{icon}";
          tooltip-format = "Power profile: {profile}\nDriver: {driver}";
          format-icons = {
            default = "PERF med";
            performance = "PERF high";
            balanced = "PERF med";
            "power-saver" = "PERF low";
          };
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
      #power-profiles-daemon,
      #pulseaudio.sink,
      #pulseaudio.mic {
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

      #power-profiles-daemon.performance {
        color: #e67e80;
      }

      #power-profiles-daemon.balanced {
        color: #dbbc7f;
      }

      #power-profiles-daemon.power-saver {
        color: #a7c080;
      }
    '';
  };
}
