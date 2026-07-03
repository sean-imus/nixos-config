{ ... }:
{
  flake.modules.nixos.desktop =
    { ... }:
    {
      services.printing.enable = true;
      hardware.sane.enable = true;
    };

  flake.modules.homeManager.desktop =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [ simple-scan ];
    };
}
