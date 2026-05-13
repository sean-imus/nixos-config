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
            "/var/lib/fwupd" # Firmware Update Metadata
            "/var/lib/systemd/coredump" # Crash Logs
            "/var/lib/systemd/timers" # Systemd Timer Information
            "/var/log" # logs so journalctl can provide info after reboot
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
            directories = [
              {
                directory = ".ssh";
                mode = "0700";
              }
              ".local/state/wireplumber" # audio configuration
              "persist"
            ];
          };
        };
      };
    };
}
