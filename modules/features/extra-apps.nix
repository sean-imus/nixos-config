{
  den.aspects.extra-apps.homeManager =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.libreoffice-stable
      ];

      services.playerctld.enable = true;

      programs.mpv = {
        enable = true;
        config = {
          hwdec = "vaapi";
          gpu-context = "wayland";
        };
      };

      xdg = {
        hiddenDesktopEntries = {
          libreoffice = {
            package = pkgs.libreoffice-stable;
            names = [
              "base"
              "draw"
              "impress"
              "math"
              "startcenter"
              "xsltfilter"
            ];
          };
          mpv = {
            package = pkgs.mpv;
            names = [ "mpv" ];
          };
        };

        mimeApps.defaultApplications = {
          "text/markdown" = "writer.desktop";
          "text/plain" = "writer.desktop";
          "text/x-markdown" = "writer.desktop";
        };
      };
    };
}
