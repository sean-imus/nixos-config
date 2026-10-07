{ pkgs, theme, ... }:
{
  gtk = {
    enable = true;
    theme = {
      name = "everforest-dark-medium";
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

  # niri/utilities.nix reads its cursor theme and size from here.
  home.pointerCursor = {
    enable = true;
    name = "everforest-cursors";
    package = pkgs.everforest-cursors;
    size = 24;
    gtk.enable = true;
  };
}
