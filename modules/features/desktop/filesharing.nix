{ ... }:
{
  flake.modules.nixos.desktop =
    { ... }:
    {
      # localsend only reachable over tailscale
      networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 53317 ];
      networking.firewall.interfaces."tailscale0".allowedUDPPorts = [ 53317 ];
    };

  flake.modules.homeManager.desktop =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.localsend ];

      programs.niri.settings.window-rules = [
        {
          matches = [ { app-id = "^localsend_app$"; } ];
          open-floating = true;
          opacity = 0.85;
          background-effect.blur = true;
        }
      ];
    };
}
