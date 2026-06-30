{ inputs, ... }:
{
  flake-file.inputs = {
    preservation = {
      url = "github:nix-community/preservation";
    };
  };

  flake.modules.nixos.persistence =
    { ... }:
    {
      imports = [ inputs.preservation.nixosModules.default ];

      preservation = {
        enable = true;
        preserveAt."/persist" = {
          directories = [
            "/var/lib/systemd/timers"
            "/var/lib/libvirt/" # Needed for VM Storage, custom Networks and such, ugly but necessery
          ];
          files = [
            {
              file = "/etc/machine-id";
              inInitrd = true;
            }
          ];
          users.sean = {
            files = [
              {
                file = ".config/sops/age/keys.txt";
                configureParent = true;
              }
            ];
            directories = [
              ".local/state/wireplumber"
              "persist"
              ".claude"
            ];
          };
        };
      };
    };
}
