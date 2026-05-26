{ lib, ... }:
{
  flake.modules.nixos.filesharing =
    { config, ... }:
    {
      options.hostCfg.filesharing.enable = lib.mkEnableOption "LocalSend firewall ports";

      config = lib.mkIf config.hostCfg.filesharing.enable {
        networking.firewall.allowedTCPPorts = [ 53317 ];
        networking.firewall.allowedUDPPorts = [ 53317 ];
      };
    };

  flake.modules.homeManager.filesharing =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.localsend ];
    };
}
