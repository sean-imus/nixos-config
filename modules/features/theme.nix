# Visual identity: the everforest "medium dark" palette and the UI font.
#
# Single source of truth for theming. Modules take `theme` as a module argument instead of
# hardcoding hex literals or font names, so restyling is one edit.
#
#   theme.hex theme.green        -> "#a7c080"
#   theme.rgba theme.green "44"  -> "a7c08044"  (8-digit, no prefix: fuzzel form)
#   theme.rgb.green              -> "167, 192, 128" (CSS rgb()/rgba())
{
  _module.args.theme =
    let
      colours = {
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
      };

      # "a7c080" -> "167, 192, 128"; TOML parses the 0x literals.
      channel = hex: toString (builtins.fromTOML "n = 0x${hex}").n;
      toRgb =
        c:
        builtins.concatStringsSep ", " [
          (channel (builtins.substring 0 2 c))
          (channel (builtins.substring 2 2 c))
          (channel (builtins.substring 4 2 c))
        ];
    in
    colours
    // {
      hex = colour: "#" + colour;
      rgba = colour: alpha: colour + alpha;
      rgb = builtins.mapAttrs (_: toRgb) colours;

      # Font family used by the terminal, bar, notifications, Gtk and the greeter
      # widgets. Point sizes stay at their call sites (they differ per surface).
      fontFamily = "JetBrainsMono Nerd Font";
    };
}
