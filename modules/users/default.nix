{ ... }:
{
  # Group bridge (not a user). Features request group membership in a neutral,
  # user-agnostic way — `userCfg.extraGroups` on the HM user — and this maps each
  # request onto the matching system account. Every host imports it.
  flake.modules.nixos.user-groups =
    { lib, config, ... }:
    {
      # Inject the request option into every HM user.
      home-manager.sharedModules = [
        (
          { lib, ... }:
          {
            options.userCfg.extraGroups = lib.mkOption {
              type = with lib.types; listOf str;
              default = [ ];
            };
          }
        )
      ];

      # Host-safety trick: only join groups that actually exist on this host, so a
      # feature can request e.g. `libvirtd` unconditionally and it's silently
      # dropped on hosts without qemu — no per-host user code, no eval error.
      users.users = lib.mapAttrs (_name: hm: {
        extraGroups = builtins.filter (g: config.users.groups ? ${g}) hm.userCfg.extraGroups;
      }) config.home-manager.users;
    };
}
