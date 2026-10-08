{ shadowDesktopEntries, ... }:
{
  flake.modules.homeManager.office =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.libreoffice-stable ];

      xdg = {
        dataFile = shadowDesktopEntries pkgs pkgs.libreoffice-stable [
          "base"
          "draw"
          "impress"
          "math"
          "startcenter"
          "xsltfilter"
        ];

        mimeApps = {
          enable = true;
          defaultApplications = {
            "text/markdown" = "writer.desktop";
            "text/plain" = "writer.desktop";
            "text/x-markdown" = "writer.desktop";
          };
        };
      };
    };
}
