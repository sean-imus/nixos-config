{ ... }:
let
  colors = import ../../lib/colors.nix;
in
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
    style = with colors; ''
      * {
        font-family: monospace;
        font-size: 11px;
        padding: 0;
        margin: 0;
      }

      window#waybar {
        background: #${bg0};
        color: #${fg};
      }

      #clock,
      #battery,
      #power-profiles-daemon,
      #pulseaudio.sink,
      #pulseaudio.mic {
        padding: 0 6px;
      }

      #battery.charging {
        color: #${green};
      }

      #battery.critical:not(.charging) {
        color: #${red};
      }

      #pulseaudio.sink.muted,
      #pulseaudio.mic.source-muted {
        color: #${grey0};
      }

      #power-profiles-daemon.performance {
        color: #${red};
      }

      #power-profiles-daemon.balanced {
        color: #${yellow};
      }

      #power-profiles-daemon.power-saver {
        color: #${green};
      }
    '';
  };
}
