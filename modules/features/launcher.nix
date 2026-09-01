{ ... }:
let
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
        background = withAlpha "2d353b";
        text = withAlpha "d3c6aa";
        prompt = withAlpha "7a8478";
        input = withAlpha "d3c6aa";
        match = withAlpha "a7c080";
        selection = "a7c08044";
        selection-text = withAlpha "d3c6aa";
        selection-match = withAlpha "a7c080";
        border = "a7c08055";
      };
      border = {
        width = 2;
        radius = 12;
      };
    };
  };
}
