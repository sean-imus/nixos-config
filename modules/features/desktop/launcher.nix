{ ... }:
{
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        dpi-aware = false;
        namespace = "fuzzel";
        icons-enabled = true;
        sort-result = false;
      };
      border = {
        width = 2;
        radius = 12;
      };
    };
  };
}
