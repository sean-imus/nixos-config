{ ... }:
{
  flake.modules.nixos.dns =
    { lib, ... }:
    {
      services.resolved = {
        enable = true;
        settings.Resolve = {
          DNSSEC = "allow-downgrade"; # compat for different types of wifi networks
          DNSOverTLS = "true";
        };
      };

      # "#cloudflare-dns.com" suffix sets the TLS SNI for cert validation.
      networking.nameservers = [
        "1.1.1.1#cloudflare-dns.com"
        "1.0.0.1#cloudflare-dns.com"
      ];

      # mkForce needed because the resolved module otherwise sets this to "systemd-resolved".
      networking.networkmanager.dns = lib.mkForce "none";
    };
}
