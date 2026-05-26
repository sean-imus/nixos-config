{ inputs, lib, ... }:
{
  flake.modules.nixos.localsend =
    { config, ... }:
    {
      options.userCfg.localsend.enable = lib.mkEnableOption "LocalSend user package";
      options.hostCfg.localsend.enable = lib.mkEnableOption "LocalSend firewall ports";

      config = lib.mkMerge [
        (lib.mkIf config.hostCfg.localsend.enable {
          networking.firewall.allowedTCPPorts = [ 53317 ];
          networking.firewall.allowedUDPPorts = [ 53317 ];
        })
        (lib.mkIf config.userCfg.localsend.enable {
          home-manager.users.sean.imports = [ inputs.self.modules.homeManager.localsend ];
        })
      ];
    };

  flake.modules.homeManager.localsend =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.localsend ];
    };
}
