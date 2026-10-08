{ shadowDesktopEntries, ... }:
{
  flake.modules = {
    nixos.printing =
      { pkgs, ... }:
      {
        services.printing.enable = true;

        hardware.sane.enable = true;

        environment.systemPackages = [ pkgs.simple-scan ];
      };

    homeManager.printing =
      { pkgs, ... }:
      {
        xdg.dataFile = shadowDesktopEntries pkgs pkgs.cups [ "cups" ];
      };
  };
}
