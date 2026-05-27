{ ... }:
{
  flake.modules.nixos.filesharing =
    { ... }:
    {
      networking.firewall.allowedTCPPorts = [ 53317 ];
      networking.firewall.allowedUDPPorts = [ 53317 ];
    };

  flake.modules.homeManager.filesharing =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.localsend ];
    };
}
