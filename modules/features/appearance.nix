{ pkgs, theme, ... }:
{
  gtk = {
    enable = true;
    theme = {
      name = "Everforest-Dark";
      package = pkgs.everforest-gtk-theme;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    font = {
      name = theme.fontFamily;
      size = 10;
    };
  };

  home.pointerCursor = {
    enable = true;
    name = "everforest-cursors";
    package = pkgs.everforest-cursors;
    size = 24;
    gtk.enable = true;
  };
}
