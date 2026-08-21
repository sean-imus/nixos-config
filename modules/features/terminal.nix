{ theme, ... }:
let
  inherit theme;
in
{
  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "${theme.font.family}:size=${toString theme.font.size}";
        term = "xterm-256color";
      };
      scrollback = {
        lines = 10000;
      };
      cursor = {
        style = "block";
      };
      colors-dark = {
        foreground = theme.fg;
        background = theme.bg0;
        regular0 = theme.bg4;
        regular1 = theme.red;
        regular2 = theme.green;
        regular3 = theme.yellow;
        regular4 = theme.blue;
        regular5 = theme.purple;
        regular6 = theme.aqua;
        regular7 = theme.fg;
        bright0 = theme.bg4;
        bright1 = theme.red;
        bright2 = theme.green;
        bright3 = theme.yellow;
        bright4 = theme.blue;
        bright5 = theme.purple;
        bright6 = theme.aqua;
        bright7 = theme.fg;
      };
    };
  };
}
