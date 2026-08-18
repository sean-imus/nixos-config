{ ... }:
{
  wayland.windowManager.niri.settings.binds = {
    "XF86AudioRaiseVolume" = {
      _props.allow-when-locked = true;
      spawn = [
        "wpctl"
        "set-volume"
        "@DEFAULT_AUDIO_SINK@"
        "0.1+"
        "-l"
        "1.0"
      ];
    };
    "XF86AudioLowerVolume" = {
      _props.allow-when-locked = true;
      spawn = [
        "wpctl"
        "set-volume"
        "@DEFAULT_AUDIO_SINK@"
        "0.1-"
      ];
    };
    "XF86AudioMute" = {
      _props.allow-when-locked = true;
      spawn = [
        "wpctl"
        "set-mute"
        "@DEFAULT_AUDIO_SINK@"
        "toggle"
      ];
    };
    "XF86AudioMicMute" = {
      _props.allow-when-locked = true;
      spawn = [
        "wpctl"
        "set-mute"
        "@DEFAULT_AUDIO_SOURCE@"
        "toggle"
      ];
    };
    "XF86AudioPlay" = {
      _props.allow-when-locked = true;
      spawn = [
        "playerctl"
        "play-pause"
      ];
    };
    "XF86AudioStop" = {
      _props.allow-when-locked = true;
      spawn = [
        "playerctl"
        "stop"
      ];
    };
    "XF86AudioPrev" = {
      _props.allow-when-locked = true;
      spawn = [
        "playerctl"
        "previous"
      ];
    };
    "XF86AudioNext" = {
      _props.allow-when-locked = true;
      spawn = [
        "playerctl"
        "next"
      ];
    };
    "XF86MonBrightnessUp" = {
      _props.allow-when-locked = true;
      spawn = [
        "brightnessctl"
        "--class=backlight"
        "set"
        "+10%"
      ];
    };
    "XF86MonBrightnessDown" = {
      _props.allow-when-locked = true;
      spawn = [
        "brightnessctl"
        "--class=backlight"
        "set"
        "10%-"
      ];
    };

    "Mod+O" = {
      _props.repeat = false;
      _props.allow-inhibiting = false;
      "toggle-overview" = { };
    };
    "Mod+Q" = {
      "close-window" = { };
    };

    "Mod+H" = {
      "focus-column-left" = { };
    };
    "Mod+J" = {
      "focus-window-or-workspace-down" = { };
    };
    "Mod+K" = {
      "focus-window-or-workspace-up" = { };
    };
    "Mod+L" = {
      "focus-column-right" = { };
    };

    "Mod+Ctrl+H" = {
      "move-column-left" = { };
    };
    "Mod+Ctrl+J" = {
      "move-window-down-or-to-workspace-down" = { };
    };
    "Mod+Ctrl+K" = {
      "move-window-up-or-to-workspace-up" = { };
    };
    "Mod+Ctrl+L" = {
      "move-column-right" = { };
    };

    "Mod+Shift+H" = {
      "focus-monitor-left" = { };
    };
    "Mod+Shift+J" = {
      "focus-monitor-down" = { };
    };
    "Mod+Shift+K" = {
      "focus-monitor-up" = { };
    };
    "Mod+Shift+L" = {
      "focus-monitor-right" = { };
    };

    "Mod+Shift+Ctrl+H" = {
      "move-column-to-monitor-left" = { };
    };
    "Mod+Shift+Ctrl+J" = {
      "move-column-to-monitor-down" = { };
    };
    "Mod+Shift+Ctrl+K" = {
      "move-column-to-monitor-up" = { };
    };
    "Mod+Shift+Ctrl+L" = {
      "move-column-to-monitor-right" = { };
    };

    "Mod+WheelScrollDown" = {
      _props.cooldown-ms = 150;
      "focus-workspace-down" = { };
    };
    "Mod+WheelScrollUp" = {
      _props.cooldown-ms = 150;
      "focus-workspace-up" = { };
    };
    "Mod+WheelScrollRight" = {
      "focus-column-right" = { };
    };
    "Mod+WheelScrollLeft" = {
      "focus-column-left" = { };
    };
    "Mod+Shift+WheelScrollDown" = {
      "focus-column-left" = { };
    };
    "Mod+Shift+WheelScrollUp" = {
      "focus-column-right" = { };
    };

    "Mod+1" = {
      "focus-workspace" = 1;
    };
    "Mod+2" = {
      "focus-workspace" = 2;
    };
    "Mod+3" = {
      "focus-workspace" = 3;
    };
    "Mod+4" = {
      "focus-workspace" = 4;
    };
    "Mod+5" = {
      "focus-workspace" = 5;
    };
    "Mod+6" = {
      "focus-workspace" = 6;
    };
    "Mod+7" = {
      "focus-workspace" = 7;
    };
    "Mod+8" = {
      "focus-workspace" = 8;
    };
    "Mod+9" = {
      "focus-workspace" = 9;
    };

    "Mod+Ctrl+1" = {
      "move-column-to-workspace" = 1;
    };
    "Mod+Ctrl+2" = {
      "move-column-to-workspace" = 2;
    };
    "Mod+Ctrl+3" = {
      "move-column-to-workspace" = 3;
    };
    "Mod+Ctrl+4" = {
      "move-column-to-workspace" = 4;
    };
    "Mod+Ctrl+5" = {
      "move-column-to-workspace" = 5;
    };
    "Mod+Ctrl+6" = {
      "move-column-to-workspace" = 6;
    };
    "Mod+Ctrl+7" = {
      "move-column-to-workspace" = 7;
    };
    "Mod+Ctrl+8" = {
      "move-column-to-workspace" = 8;
    };
    "Mod+Ctrl+9" = {
      "move-column-to-workspace" = 9;
    };

    "Mod+Comma" = {
      "consume-or-expel-window-left" = { };
    };
    "Mod+Period" = {
      "consume-or-expel-window-right" = { };
    };

    "Mod+F" = {
      "maximize-column" = { };
    };
    "Mod+Shift+F" = {
      "fullscreen-window" = { };
    };
    "Mod+Ctrl+F" = {
      "maximize-window-to-edges" = { };
    };

    "Mod+Minus" = {
      "set-column-width" = "-10%";
    };
    "Mod+Plus" = {
      "set-column-width" = "+10%";
    };
    "Mod+Shift+Minus" = {
      "set-window-height" = "-10%";
    };
    "Mod+Shift+Plus" = {
      "set-window-height" = "+10%";
    };

    "Mod+V" = {
      "toggle-window-floating" = { };
    };
    "Mod+Shift+V" = {
      "switch-focus-between-floating-and-tiling" = { };
    };

    "Mod+C" = {
      "screenshot" = { };
    };
    "Mod+Ctrl+C" = {
      "screenshot-screen" = { };
    };
    "Mod+Shift+C" = {
      "screenshot-window" = { };
    };

    "Mod+Escape" = {
      _props.allow-inhibiting = false;
      "toggle-keyboard-shortcuts-inhibit" = { };
    };

    "Mod+Shift+E" = {
      "quit" = { };
    };

    "Mod+Space" = {
      spawn = "fuzzel";
    };

    "Mod+T" = {
      spawn = "kitty";
    };

    "Mod+Shift+Space" = {
      spawn = [
        "sh"
        "-c"
        "pkill waybar || true && waybar"
      ];
    };

    "Mod+Ctrl+Space" = {
      spawn = [
        "sh"
        "-c"
        "pkill waybar"
      ];
    };

    "Super+Alt+L" = {
      spawn = "hyprlock";
    };

    "Mod+Ctrl+B" = {
      spawn = [
        "kitty"
        "--class"
        "bluetui"
        "bluetui"
      ];
    };

    "Mod+Ctrl+A" = {
      spawn = [
        "kitty"
        "--class"
        "wiremix"
        "wiremix"
        "-v"
        "playback"
      ];
    };

    "Mod+Ctrl+Y" = {
      spawn = [
        "sh"
        "-c"
        "cliphist list | fuzzel --dmenu --with-nth 2 | cliphist decode | wl-copy"
      ];
    };
  };
}
