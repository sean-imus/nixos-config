{ inputs, ... }:
{
  flake.modules.nixos.tailscale =
    { config, ... }:
    {
      imports = [ inputs.self.modules.nixos.sops ];

      sops.secrets.tailscale_authkey = { };

      services.tailscale = {
        enable = true;
        authKeyFile = config.sops.secrets.tailscale_authkey.path;
        extraUpFlags = [
          "--accept-routes=false"
          "--accept-dns=false" # keep the Cloudflare DoT setup (see dns.nix) authoritative
        ];
      };

      networking.firewall.trustedInterfaces = [ "tailscale0" ];
    };
}
