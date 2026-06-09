{ pkgs, ... }:
{
  flake.modules.homeManager.gtk = {
    gtk = {
      enable = true;
      theme = {
        name = "Everforest-Dark-BL";
        package = pkgs.everforest-gtk-theme;
      };
      cursorTheme = {
        name = "Everforest-cursors";
        package = pkgs.everforest-cursors;
        size = 24;
      };
    };

    home.sessionVariables.XCURSOR_THEME = "Everforest-cursors";
  };
}
