# Visual identity: the everforest "medium dark" palette and the UI font.
#
# Single source of truth for theming. Modules import this file instead of
# hardcoding hex literals or font names, so restyling is one edit.
#
#   theme.hex theme.green        -> "#a7c080"
#   theme.rgba theme.green "44"  -> "a7c08044"  (8-digit, no prefix: fuzzel form)
#   theme.rgb.green              -> "167, 192, 128" (CSS rgb()/rgba())
rec {
  bg0 = "2d353b";
  bg1 = "343f44";
  bg2 = "3d484d";
  bg3 = "475258";
  bg4 = "4f585e";

  grey0 = "7a8478";
  grey1 = "859289";
  grey2 = "9da9a0";

  fg = "d3c6aa";

  red = "e67e80";
  orange = "e69875";
  yellow = "dbbc7f";
  green = "a7c080";
  aqua = "83c092";
  blue = "7fbbb3";
  purple = "d699b6";

  hex = colour: "#" + colour;
  rgba = colour: alpha: colour + alpha;

  rgb = {
    bg0 = "45, 53, 59";
    bg1 = "52, 63, 68";
    bg2 = "61, 72, 77";
    bg3 = "71, 82, 88";
    bg4 = "79, 88, 94";

    grey0 = "122, 132, 120";
    grey1 = "133, 146, 137";
    grey2 = "157, 169, 160";

    fg = "211, 198, 170";

    red = "230, 126, 128";
    orange = "230, 152, 117";
    yellow = "219, 188, 127";
    green = "167, 192, 128";
    aqua = "131, 192, 146";
    blue = "127, 187, 179";
    purple = "214, 153, 182";
  };

  # Font family used by the terminal, bar, notifications, Gtk and the greeter
  # widgets. Point sizes stay at their call sites (they differ per surface).
  fontFamily = "JetBrainsMono Nerd Font";
}
