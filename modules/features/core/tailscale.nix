{ ... }:
{
  flake.modules.nixos.tailscale =
    { ... }:
    {
      services.tailscale.enable = false;

      networking.firewall.trustedInterfaces = [ "tailscale0" ];
    };
}
