_:
let
  theme = import ../lib/theme.nix;
in
{
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        dpi-aware = false;
        namespace = "fuzzel";
        sort-result = false;
        icons-enabled = false;
      };
      colors = {
        background = theme.rgba theme.bg0 "ff";
        text = theme.rgba theme.fg "ff";
        prompt = theme.rgba theme.grey0 "ff";
        input = theme.rgba theme.fg "ff";
        match = theme.rgba theme.green "ff";
        selection = theme.rgba theme.green "44";
        selection-text = theme.rgba theme.fg "ff";
        selection-match = theme.rgba theme.green "ff";
        border = theme.rgba theme.green "ff";
      };
      border = {
        width = 2;
        radius = 0;
      };
    };
  };
}
