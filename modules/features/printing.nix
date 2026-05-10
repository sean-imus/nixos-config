{ ... }:
{
  flake.modules.nixos.printing = {
    services.printing.enable = true;
    hardware.sane.enable = true;
  };

  flake.modules.homeManager.printing =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [ simple-scan ];
    };
}
