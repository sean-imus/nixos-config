{ inputs, ... }:
{
  flake-file.inputs = {
    preservation = {
      url = "github:nix-community/preservation";
    };
  };

  flake.modules.nixos.impermanence =
    { ... }:
    {
      imports = [ inputs.preservation.nixosModules.default ];

      preservation = {
        enable = true;
        preserveAt."/persist" = {
          directories = [
            "/etc/NetworkManager/system-connections" # WiFi Password
            "/var/lib/bluetooth" # Bluetooth Connections
            "/var/lib/systemd/timers" # Systemd Timer Information
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
              ".local/state/wireplumber" # audio configuration
              "persist"
            ];
          };
        };
      };
    };
}
