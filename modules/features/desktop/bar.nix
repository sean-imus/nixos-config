{ inputs, lib, ... }:
{
  flake.modules.nixos.bar = { config, ... }: {
    options.userCfg.bar.enable = lib.mkEnableOption "Waybar status bar";
    config = lib.mkIf config.userCfg.bar.enable {
      home-manager.users.sean.imports = [ inputs.self.modules.homeManager.bar ];
    };
  };

  flake.modules.homeManager.bar =
    { lib, ... }:
    {
      programs.waybar = {
        enable = true;
        settings = [
          {
            reload_style_on_change = true;
            spacing = 4;
            height = 0;
            margin = "5";
            modules-left = [
              "niri/workspaces"
              "cava"
              "custom/recording"
            ];
            modules-center = [
              "clock"
            ];
            modules-right = [
              "mpris"
              "pulseaudio#sink"
              "pulseaudio#mic"
              "network"
              "cpu"
              "power-profiles-daemon"
              "memory"
              "battery"
            ];
            "niri/workspaces" = {
              format = "{icon}";
              format-icons = {
                empty = "○";
                default = "●";
              };
              workspace-taskbar = {
                enable = true;
                icon-size = 16;
              };
            };
            clock = {
              format = "{:%H:%M  %d.%m.%Y}";
              tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
              calendar = {
                mode = "year";
                mode-mon-col = 4;
                weeks-pos = "left";
                on-scroll = 1;
                format = {
                  months = "<span color='#ffead3'><b>{}</b></span>";
                  days = "<span color='#ecc6d9'><b>{}</b></span>";
                  weeks = "<span color='#99ffdd'><b>W{}</b></span>";
                  weekdays = "<span color='#ffcc66'><b>{}</b></span>";
                  today = "<span color='#ff6699'><b><u>{}</u></b></span>";
                };
              };
              actions = {
                on-click-right = "mode";
                on-scroll-up = "shift_down";
                on-scroll-down = "shift_up";
              };
            };
            cpu = {
              format = "cpu {usage}%";
              on-click = "alacritty --class btop -e btop";
            };
            "power-profiles-daemon" = {
              format = "{icon}";
              format-icons = {
                power-saver = "perf low";
                balanced = "perf mid";
                performance = "perf high";
              };
              tooltip = false;
            };
            memory = {
              format = "mem {}%";
            };
            battery = {
              states = {
                warning = 30;
                critical = 15;
              };
              format = "batt {capacity}%";
            };
            network = {
              format-wifi = "wifi {signalStrength}%";
              format-ethernet = "eth";
              tooltip-format = "{ifname}";
              format-disconnected = "<s>net</s>";
              on-click = "alacritty --class netpala -e netpala";
            };
            "pulseaudio#sink" = {
              format = "vol {volume}%";
              format-muted = "<s>vol</s>";
              scroll-step = 5;
              on-click = "alacritty --class wiremix -e wiremix -v output";
            };
            "custom/recording" = {
              exec = "cat /tmp/waybar-recording 2>/dev/null || echo '{\"text\": \"\"}'";
              return-type = "json";
              signal = 8;
              on-click = "rm -f /tmp/waybar-recording /tmp/screencap-pid; kill $(cat /tmp/screencap-pid 2>/dev/null) 2>/dev/null; pkill -x wf-recorder; pkill -RTMIN+8 waybar";
            };
            mpris = {
              format = "{status_icon} {dynamic}";
              format-stopped = "Nothing playing!";
              status-icons = {
                playing = "♫";
                paused = "⏸";
              };
              dynamic-order = [
                "title"
                "artist"
              ];
              dynamic-separator = " - ";
              max-length = 50;
            };
            cava = {
              bars = 14;
              method = "pipewire";
              sleep_timer = 5;
              bar_delimiter = 0;
              hide_on_silence = true;
              format-icons = [
                "▁"
                "▂"
                "▃"
                "▄"
                "▅"
                "▆"
                "▇"
                "█"
              ];
              actions = {
                on-click-right = "mode";
              };
            };
            "pulseaudio#mic" = {
              format = "{format_source}";
              format-source = "mic {volume}%";
              format-source-muted = "<s>mic</s>";
              scroll-step = 5;
              on-click = "alacritty --class wiremix -e wiremix -v input";
              on-scroll-up = "wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 5%+ -l 1.0";
              on-scroll-down = "wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 5%-";
            };
          }
        ];
        style = ''
          @define-color bg                rgba(0, 0, 0, 0.5);
          @define-color fg                rgba(255, 255, 255, 1);
          @define-color battery-fg        rgba(0, 0, 0, 1);
          @define-color battery-bg        rgba(255, 255, 255, 0.8);
          @define-color battery-charging  rgba(38, 166, 91, 0.8);
          @define-color critical          rgba(245, 60, 60, 0.8);
          @define-color perf-bg           rgba(230, 180, 50, 0.8);
          @define-color cpu-bg            rgba(67, 115, 6, 0.8);
          @define-color memory-bg         rgba(155, 89, 182, 0.8);
          @define-color network-bg        rgba(41, 128, 185, 0.8);
          @define-color audio-bg          rgba(165, 133, 4, 0.8);
          @define-color audio-muted-bg    rgba(144, 177, 177, 0.8);
          @define-color ws-focused-bg     rgba(214, 55, 51, 0.8);
          @define-color recording-fg      rgba(255, 51, 51, 1);
          @define-color recording-bg      rgba(214, 55, 51, 0.8);

          * {
              font-family: Arial;
              font-size: 13px;
          }

          window#waybar {
              background: @bg;
              border-radius: 15px;
          }

          .modules-right label,
          .modules-right box {
              padding: 0px 9px;
              margin: 6px 2px;
              color: @fg;
              border-radius: 15px;
          }

          .modules-center label,
          .modules-center box {
              padding: 0px 9px;
              margin: 6px 2px;
              color: @fg;
              border-radius: 15px;
          }

          .modules-left label,
          .modules-left box {
              padding: 0px 4px;
              margin: 4px 5px;
              color: @fg;
              border-radius: 15px;
          }

          #mpris {
              background-color: @audio-bg;
          }

          #cava {
              padding: 0px 4px;
              min-width: 100px;
              min-height: 20px;
              background-color: transparent;
          }

          #battery {
              background-color: @battery-bg;
              color: @battery-fg;
          }

          #battery.charging,
          #battery.plugged {
              color: @fg;
              background-color: @battery-charging;
          }

          #battery.critical:not(.charging) {
              background-color: @critical;
              color: @fg;
              animation-name: blink;
              animation-duration: 0.5s;
              animation-timing-function: steps(30);
              animation-iteration-count: infinite;
              animation-direction: alternate;
          }

          @keyframes blink {
              to {
                  background-color: @battery-bg;
                  color: @battery-fg;
              }
          }

          #cpu {
              background-color: @cpu-bg;
          }

          #power-profiles-daemon {
              background-color: @perf-bg;
          }

          #power-profiles-daemon.power-saver {
              background-color: @network-bg;
          }

          #power-profiles-daemon.performance {
              background-color: @critical;
          }

          #memory {
              background-color: @memory-bg;
          }

          #network {
              background-color: @network-bg;
          }

          #network.disconnected {
              background-color: @critical;
          }

          #pulseaudio.sink,
          #pulseaudio.mic {
              background-color: @audio-bg;
          }

          #pulseaudio.sink.muted,
          #pulseaudio.mic.source-muted {
              background-color: @audio-muted-bg;
          }

          #clock {
              background-color: transparent;
          }

          #custom-recording {
              padding: 0px 5px;
              margin: 4px 5px;
              background-color: transparent;
              color: @recording-fg;
          }

          #custom-recording.recording {
              background-color: @recording-bg;
              color: @fg;
              min-width: 20px;
          }

          #workspaces {
              background-color: transparent;
          }

          #workspaces button {
              padding: 0px 2px;
              border-radius: 15px;
          }

          #workspaces button.focused {
              background-color: @ws-focused-bg;
          }

          #workspaces button.urgent {
              background-color: @critical;
          }

          .modules-right {
              margin-right: 5px;
          }
        '';
      };

      programs.niri.settings.spawn-at-startup = lib.mkBefore [
        { argv = [ "waybar" ]; }
      ];
    };
}
