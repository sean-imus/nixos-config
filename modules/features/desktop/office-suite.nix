{ ... }:
{
  flake.modules.homeManager.office-suite =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.libreoffice-fresh ];

      xdg.dataFile = builtins.listToAttrs (
        map
          (name: {
            name = "applications/${name}.desktop";
            value.text = "[Desktop Entry]\nHidden=true\n";
          })
          [
            "base"
            "draw"
            "impress"
            "math"
            "startcenter"
            "xsltfilter"
          ]
      );
    };
}
