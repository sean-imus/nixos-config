{ inputs, ... }:
{
  # Use preservation to persist files & folders on an impermanent root
  flake-file.inputs = {
    preservation = {
      url = "github:nix-community/preservation";
    };
  };

  flake.modules.nixos.persistence =
    { lib, config, ... }:
    {
      # Import preservations NixOS module to use its options
      imports = [ inputs.preservation.nixosModules.default ];

      # This does not work on an impermanent NixOS system, instead the machine-id is preserved below
      systemd.services."systemd-machine-id-commit".enable = false;

      home-manager.sharedModules = [
        (
          { ... }:
          {
            # Functionality to allow Home-Manager modules to declare the files they need persisted themselves
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
            # Everyone gets a user owned persisted directory under ~/persist
            config.persist.directories = [ "persist" ];
          }
        )
      ];

      # Actual logic that moves files we want persisted to the correct locations at boot
      preservation = {
        enable = true;
        preserveAt."/persist" = {
          directories = [
            # Needed so anything timer based knows when it last ran (Nix-Store optimization / old NixOS generation cleanup)
            "/var/lib/systemd/timers"
          ];
          files = [
            {
              # This is needed so the host has an actual machine-id since we disabled systemd from committing it
              file = "/etc/machine-id";
              inInitrd = true;
            }
          ];
          # Logic that maps any persisted files / directories from Home-Manager modules to the preservation module for all users
          users = lib.mapAttrs (_name: hm: {
            inherit (hm.persist) files directories;
          }) config.home-manager.users;
        };
      };
    };
}
