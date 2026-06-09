{ ... }:
{
  flake.modules.homeManager.gtk =
    { pkgs, config, ... }:
    {
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
        gtk4.theme = config.gtk.theme;
      };

      home.sessionVariables.XCURSOR_THEME = "Everforest-cursors";
    };
}
