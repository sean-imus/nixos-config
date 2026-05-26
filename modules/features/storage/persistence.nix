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
            "/etc/NetworkManager/system-connections"
            "/var/lib/systemd/timers"
            "/var/lib/libvirt/" # Needed for VM Storage, custom Networks and such, ugly but necessery
          ];
          files = [
            {
              file = "/etc/machine-id";
              inInitrd = true;
            }
            {
              file = "/etc/ssh/ssh_host_rsa_key";
              how = "symlink";
              configureParent = true;
            }
            {
              file = "/etc/ssh/ssh_host_ed25519_key";
              how = "symlink";
              configureParent = true;
            }
          ];
          users.sean = {
            files = [
              {
                file = ".ssh/sops_age_key";
                configureParent = true;
              }
            ];
            directories = [
              ".local/state/wireplumber"
              "persist"
            ];
          };
        };
      };
    };
}
