{ ... }:
{
  programs.btop = {
    enable = true;
    settings = {
      update_ms = 1000;
      color_theme = "everforest-dark-medium";
    };
  };
}
