{ lib, ... }:
let
  locked = bind: { _props.allow-when-locked = true; } // bind;

  tui = app-id: args: {
    spawn = [
      "foot"
      "--app-id"
      app-id
    ]
    ++ args;
  };

  workspaceBinds = lib.listToAttrs (
    lib.concatMap (
      n:
      let
        key = toString n;
      in
      [
        (lib.nameValuePair "Mod+${key}" { focus-workspace = n; })
        (lib.nameValuePair "Mod+Ctrl+${key}" { move-column-to-workspace = n; })
      ]
    ) (lib.range 1 9)
  );
in
{
  wayland.windowManager.niri.settings = {
    recent-windows.binds = {
      "Mod+Tab".next-window = { };
      "Mod+Shift+Tab".previous-window = { };
    };

    binds = workspaceBinds // {
      "XF86AudioRaiseVolume" = locked { spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0"; };
      "XF86AudioLowerVolume" = locked { spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-"; };
      "XF86AudioMute" = locked { spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"; };
      "XF86AudioMicMute" = locked { spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"; };
      "XF86AudioPlay" = locked { spawn-sh = "playerctl play-pause"; };
      "XF86AudioStop" = locked { spawn-sh = "playerctl stop"; };
      "XF86AudioPrev" = locked { spawn-sh = "playerctl previous"; };
      "XF86AudioNext" = locked { spawn-sh = "playerctl next"; };
      "XF86MonBrightnessUp" = locked {
        spawn-sh = "quickshell -c qs-shell ipc call brightness poke & brightnessctl --class=backlight set +10%; wait";
      };
      "XF86MonBrightnessDown" = locked {
        spawn-sh = "quickshell -c qs-shell ipc call brightness poke & brightnessctl --class=backlight set 10%-; wait";
      };

      "Mod+O" = {
        _props.repeat = false;
        _props.allow-inhibiting = false;
        toggle-overview = { };
      };
      "Mod+Q".close-window = { };

      "Mod+H".focus-column-left = { };
      "Mod+J".focus-window-or-workspace-down = { };
      "Mod+K".focus-window-or-workspace-up = { };
      "Mod+L".focus-column-right = { };

      "Mod+Shift+H".move-column-left = { };
      "Mod+Shift+J".move-window-down-or-to-workspace-down = { };
      "Mod+Shift+K".move-window-up-or-to-workspace-up = { };
      "Mod+Shift+L".move-column-right = { };

      "Mod+Ctrl+H".focus-monitor-left = { };
      "Mod+Ctrl+J".focus-monitor-down = { };
      "Mod+Ctrl+K".focus-monitor-up = { };
      "Mod+Ctrl+L".focus-monitor-right = { };

      "Mod+Shift+Ctrl+H".move-column-to-monitor-left = { };
      "Mod+Shift+Ctrl+J".move-column-to-monitor-down = { };
      "Mod+Shift+Ctrl+K".move-column-to-monitor-up = { };
      "Mod+Shift+Ctrl+L".move-column-to-monitor-right = { };

      "Mod+WheelScrollDown" = {
        _props.cooldown-ms = 150;
        focus-workspace-down = { };
      };
      "Mod+WheelScrollUp" = {
        _props.cooldown-ms = 150;
        focus-workspace-up = { };
      };
      "Mod+WheelScrollRight".focus-column-right = { };
      "Mod+WheelScrollLeft".focus-column-left = { };
      "Mod+Shift+WheelScrollDown".focus-column-left = { };
      "Mod+Shift+WheelScrollUp".focus-column-right = { };

      "Mod+Comma".consume-or-expel-window-left = { };
      "Mod+Period".consume-or-expel-window-right = { };

      "Mod+F".maximize-column = { };
      "Mod+Shift+F".fullscreen-window = { };
      "Mod+Ctrl+F".maximize-window-to-edges = { };

      "Mod+Minus".set-column-width = "-10%";
      "Mod+Plus".set-column-width = "+10%";
      "Mod+Shift+Minus".set-window-height = "-10%";
      "Mod+Shift+Plus".set-window-height = "+10%";

      "Mod+V".toggle-window-floating = { };
      "Mod+Shift+V".switch-focus-between-floating-and-tiling = { };

      "Mod+C".screenshot = { };
      "Mod+Shift+C".screenshot-window = { };

      "Mod+Escape" = {
        _props.allow-inhibiting = false;
        toggle-keyboard-shortcuts-inhibit = { };
      };

      "Mod+Shift+E".quit = { };

      "Mod+Space".spawn = "fuzzel";
      "Mod+T".spawn = "foot";
      "Mod+B".spawn = "chromium-privat";
      "Mod+Ctrl+B" = tui "bluetui" [ "bluetui" ];
      "Mod+Ctrl+A" = tui "wiremix" [
        "wiremix"
        "-v"
        "playback"
      ];
      "Mod+Ctrl+T" = tui "btop" [ "btop" ];
      "Mod+Ctrl+Y".spawn-sh = "cliphist list | fuzzel --dmenu --with-nth 2 | cliphist decode | wl-copy";
    };
  };
}
