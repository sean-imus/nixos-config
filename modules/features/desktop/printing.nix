{ lib, ... }:
{
  flake.modules.nixos.printing =
    { config, ... }:
    {
      options.hostCfg.printing.enable = lib.mkEnableOption "CUPS printing and SANE scanner support";

      config = lib.mkIf config.hostCfg.printing.enable {
        services.printing.enable = true;
        hardware.sane.enable = true;
      };
    };

  flake.modules.homeManager.printing =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [ simple-scan ];
    };
}
