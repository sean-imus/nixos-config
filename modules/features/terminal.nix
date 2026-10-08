{ theme, shadowDesktopEntries, ... }:
{
  flake.modules.homeManager.terminal =
    { lib, pkgs, ... }:
    let
      ansi = map (name: theme.${name}) [
        "bg4"
        "red"
        "green"
        "yellow"
        "blue"
        "purple"
        "aqua"
        "fg"
      ];
      indexed =
        prefix: lib.listToAttrs (lib.imap0 (i: c: lib.nameValuePair "${prefix}${toString i}" c) ansi);
    in
    {
      programs.foot = {
        enable = true;
        settings = {
          main = {
            font = "${theme.fontFamily}:size=10";
            term = "xterm-256color";
          };
          scrollback.lines = 10000;
          cursor.style = "beam";
          colors-dark = {
            foreground = theme.fg;
            background = theme.bg0;
          }
          // indexed "regular"
          // indexed "bright";
        };
      };

      xdg.dataFile = shadowDesktopEntries pkgs pkgs.foot [
        "foot"
        "footclient"
        "foot-server"
      ];

      wayland.windowManager.niri.settings.binds."Mod+T".spawn = "foot";
    };
}
