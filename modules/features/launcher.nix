{ ... }:
let
  colors = import ../../lib/colors.nix;
  withAlpha = hex: hex + "ff";
in
{
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        dpi-aware = false;
        namespace = "fuzzel";
        sort-result = false;
      };
      colors = {
        background = withAlpha colors.bg0;
        text = withAlpha colors.fg;
        prompt = withAlpha colors.grey0;
        input = withAlpha colors.fg;
        match = withAlpha colors.green;
        selection = colors.green + "44";
        selection-text = withAlpha colors.fg;
        selection-match = withAlpha colors.green;
        border = colors.green + "55";
      };
      border = {
        width = 2;
        radius = 12;
      };
    };
  };
}
