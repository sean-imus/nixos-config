{
  den.aspects.printing = {
    nixos =
      { pkgs, ... }:
      {
        services.printing.enable = true;
        hardware.sane.enable = true;
        environment.systemPackages = [ pkgs.simple-scan ];
      };

    homeManager =
      { pkgs, ... }:
      {
        xdg.hiddenDesktopEntries.cups = {
          package = pkgs.cups;
          names = [ "cups" ];
        };
      };
  };
}
