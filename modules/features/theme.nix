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

      channel = hex: (builtins.fromTOML "n = 0x${hex}").n;
      toRgb =
        c:
        map (i: channel (builtins.substring i 2 c)) [
          0
          2
          4
        ];
    in
    colours
    // {
      palette = colours;
      hex = colour: "#" + colour;
      rgba = colour: alpha: colour + alpha;
      rgb = builtins.mapAttrs (_: toRgb) colours;
      fontFamily = "JetBrainsMono Nerd Font";
    };
}
