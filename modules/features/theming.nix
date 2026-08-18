{ pkgs, ... }:
{
  home.packages = with pkgs; [
    everforest-cursors
    everforest-gtk-theme
  ];

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
    cursorTheme = {
      name = "everforest-cursors";
      package = pkgs.everforest-cursors;
    };
    font = {
      name = "JetBrainsMono Nerd Font";
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
