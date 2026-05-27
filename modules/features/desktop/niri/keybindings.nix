{ ... }:
{
  flake.modules.homeManager.niri-keybindings =
    { ... }:
    {
      programs.niri.settings.binds = {
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

        "Mod+T" = {
          action.spawn = "alacritty";
        };
        "Mod+B" = {
          action.spawn = "firefox";
        };
        "Mod+Ctrl+B" = {
          action.spawn = [
            "alacritty"
            "--class"
            "bluetui"
            "-e"
            "bluetui"
          ];
        };
        "Mod+Ctrl+A" = {
          action.spawn = [
            "alacritty"
            "--class"
            "wiremix"
            "-e"
            "wiremix"
            "-v"
            "playback"
          ];
        };
        "Mod+Ctrl+W" = {
          action.spawn = [
            "alacritty"
            "--class"
            "netpala"
            "-e"
            "netpala"
          ];
        };
        "Mod+Shift+Space" = {
          action.spawn = [
            "sh"
            "-c"
            "pkill waybar || true && waybar"
          ];
        };
        "Mod+Ctrl+Space" = {
          action.spawn = [
            "sh"
            "-c"
            "pkill waybar"
          ];
        };
        "Mod+P" = {
          action.spawn = "power-toggle";
        };
        "Mod+Ctrl+Shift+C" = {
          action.spawn = "screencap";
        };
      };
    };
}
