{ inputs, ... }:
{
  flake-file.inputs = {
    preservation = {
      url = "github:nix-community/preservation";
    };
  };

  # Preservation *mechanism* only: enables impermanence, holds globally-owned
  # system state, and hosts the per-user persist bridge. It must NOT enumerate
  # feature paths — each feature declares what it needs preserved in its own
  # module (system paths directly, per-user paths via the `persist.*` option).
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
            # Bridge: features write user-agnostic paths into persist.*, and the
            # mapAttrs below resolves them per-user — no feature names a user.
            options.persist = {
              files = lib.mkOption {
                type = with lib.types; listOf (either str (attrsOf anything));
                default = [ ];
              };
              directories = lib.mkOption {
                type = with lib.types; listOf (either str (attrsOf anything));
                default = [ ];
              };
            };
            config.persist.directories = [ "persist" ]; # everyone gets ~/persist (where this repo lives)
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
