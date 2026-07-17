{ inputs, ... }:
{
  flake-file.inputs = {
    preservation = {
      url = "github:nix-community/preservation";
    };
  };

  flake.modules.nixos.persistence =
    { lib, config, ... }:
    {
      imports = [ inputs.preservation.nixosModules.default ];

      # Root is tmpfs; committing a machine-id would try to write it back to the
      # wiped root. /etc/machine-id is preserved as a file below instead.
      systemd.services."systemd-machine-id-commit".enable = false;

      home-manager.sharedModules = [
        (
          { lib, ... }:
          {
            options.persist = {
              files = lib.mkOption {
                type = with lib.types; listOf (either str (attrsOf anything));
                default = [ ];
              };
              directories = lib.mkOption {
                type = with lib.types; listOf (either str (attrsOf anything));
                default = [ ];
              };
              # functionality to allow modules to declare the files they need inside themselves
            };
            config.persist.directories = [ "persist" ]; # everyone gets a user owned persisted dir under ~/persist
          }
        )
      ];

      preservation = {
        enable = true;
        preserveAt."/persist" = {
          directories = [
            "/var/lib/systemd/timers"
          ];
          files = [
            {
              file = "/etc/machine-id";
              inInitrd = true;
            }
          ];
          users = lib.mapAttrs (_name: hm: {
            inherit (hm.persist) files directories;
          }) config.home-manager.users;
        };
      };
    };
}
