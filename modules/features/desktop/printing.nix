{ inputs, lib, ... }:
{
  flake.modules.nixos.printing =
    { config, ... }:
    {
      options.userCfg.printing.enable = lib.mkEnableOption "Printing user tools (simple-scan)";
      options.hostCfg.printing.enable = lib.mkEnableOption "CUPS printing and SANE scanner support";

      config = lib.mkMerge [
        (lib.mkIf config.hostCfg.printing.enable {
          services.printing.enable = true;
          hardware.sane.enable = true;
        })
        (lib.mkIf config.userCfg.printing.enable {
          home-manager.users.sean.imports = [ inputs.self.modules.homeManager.printing ];
        })
      ];
    };

  flake.modules.homeManager.printing =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [ simple-scan ];
    };
}
