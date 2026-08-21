{ ... }:
let
  colors = import ../../lib/colors.nix;
in
{
  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "JetBrainsMono Nerd Font:size=10";
        term = "xterm-256color";
      };
      scrollback = {
        lines = 10000;
      };
      cursor = {
        style = "block";
      };
      colors-dark = {
        foreground = colors.fg;
        background = colors.bg0;
        regular0 = colors.bg4;
        regular1 = colors.red;
        regular2 = colors.green;
        regular3 = colors.yellow;
        regular4 = colors.blue;
        regular5 = colors.purple;
        regular6 = colors.aqua;
        regular7 = colors.fg;
        bright0 = colors.bg4;
        bright1 = colors.red;
        bright2 = colors.green;
        bright3 = colors.yellow;
        bright4 = colors.blue;
        bright5 = colors.purple;
        bright6 = colors.aqua;
        bright7 = colors.fg;
      };
    };
  };
}
