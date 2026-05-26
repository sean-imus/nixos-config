{ lib, ... }:
{
  flake.modules.nixos.localsend =
    { config, ... }:
    {
      options.hostCfg.localsend.enable = lib.mkEnableOption "LocalSend firewall ports";

      config = lib.mkIf config.hostCfg.localsend.enable {
        networking.firewall.allowedTCPPorts = [ 53317 ];
        networking.firewall.allowedUDPPorts = [ 53317 ];
      };
    };

  flake.modules.homeManager.localsend =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.localsend ];
    };
}
