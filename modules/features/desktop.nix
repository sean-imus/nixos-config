{ den, ... }:
{
  den.aspects.desktop.includes = with den.aspects; [
    audio
    bluetooth
    desktop-shell
    launcher
    lockscreen
    niri
    theme
  ];
}
