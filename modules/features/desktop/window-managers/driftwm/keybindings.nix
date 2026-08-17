{
  "mod+return" = "exec-terminal";
  "mod+d" = "exec-launcher";
  "mod+space" = "exec-fuzzel";
  "mod+t" = "exec-terminal";

  "mod+q" = "close-window";
  "mod+f" = "toggle-fullscreen";
  "mod+v" = "toggle-floating";
  "mod+shift+v" = "toggle-focus-floating";
  "mod+shift+e" = "quit";

  "mod+l" = "spawn hyprlock";

  "mod+left" = "center-nearest left";
  "mod+down" = "center-nearest down";
  "mod+up" = "center-nearest up";
  "mod+right" = "center-nearest right";

  "mod+shift+left" = "nudge-window left";
  "mod+shift+down" = "nudge-window down";
  "mod+shift+up" = "nudge-window up";
  "mod+shift+right" = "nudge-window right";

  "mod+ctrl+left" = "pan-viewport left";
  "mod+ctrl+down" = "pan-viewport down";
  "mod+ctrl+up" = "pan-viewport up";
  "mod+ctrl+right" = "pan-viewport right";

  "mod+alt+left" = "send-to-output left";
  "mod+alt+down" = "send-to-output down";
  "mod+alt+up" = "send-to-output up";
  "mod+alt+right" = "send-to-output right";

  "alt+tab" = "cycle-windows forward";
  "alt+shift+tab" = "cycle-windows backward";

  "mod+c" = "center-window";
  "mod+x" = "focus-center";
  "mod+a" = "home-toggle";
  "mod+m" = "fit-window";
  "mod+shift+m" = "fit-window-snapped";
  "mod+g" = "fill-window";
  "mod+shift+t" = "toggle-pin-to-screen";

  "mod+equal" = "zoom-in";
  "mod+minus" = "zoom-out";
  "mod+0" = "zoom-reset";
  "mod+z" = "zoom-reset";
  "mod+w" = "zoom-to-fit";
  "mod+shift+w" = "zoom-to-fit-snapped";

  "mod+1" = "go-to-bookmark 1";
  "mod+2" = "go-to-bookmark 2";
  "mod+3" = "go-to-bookmark 3";
  "mod+4" = "go-to-bookmark 4";
  "mod+shift+1" = "set-bookmark 1";
  "mod+shift+2" = "set-bookmark 2";
  "mod+shift+3" = "set-bookmark 3";
  "mod+shift+4" = "set-bookmark 4";

  "print" = "spawn grim - | wl-copy";
  "shift+print" = "spawn grim -g \"$(slurp -d)\" - | wl-copy";

  "XF86AudioRaiseVolume" = "spawn wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
  "XF86AudioLowerVolume" = "spawn wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
  "XF86AudioMute" = "spawn wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
  "XF86MonBrightnessUp" = "spawn brightnessctl set +5%";
  "XF86MonBrightnessDown" = "spawn brightnessctl set 5%-";
  "XF86AudioPlay" = "spawn playerctl play-pause";
  "XF86AudioPause" = "spawn playerctl play-pause";
  "XF86AudioNext" = "spawn playerctl next";
  "XF86AudioPrev" = "spawn playerctl previous";
  "XF86AudioStop" = "spawn playerctl stop";

  "mod+ctrl+b" = "spawn kitty --class bluetui bluetui";
  "mod+ctrl+a" = "spawn kitty --class wiremix wiremix -v playback";
  "mod+y" = "spawn sh -c 'cliphist list | fuzzel --dmenu --with-nth 2 | cliphist decode | wl-copy'";
}
