{ ... }:
{
  # Per-user group-membership bridge — the group analog of the persist bridge.
  #
  # A feature module (home-manager) declares a neutral, user-agnostic request:
  #   config.userCfg.extraGroups = [ "libvirtd" ];
  # Because the option is injected into every HM user tree via sharedModules, the
  # request auto-scopes to whichever user imports that feature — no feature ever
  # names a user.
  #
  # The NixOS-level bridge maps each HM user's request onto their system account,
  # filtering by groups that actually exist on the host. That existence-filter is
  # what keeps the request host-safe and user-indifferent: a user can request
  # "libvirtd" unconditionally, but only joins it on hosts where qemu created the
  # group. On hosts without it, the request is silently dropped — no eval error,
  # no per-host user code.
  flake.modules.nixos.user-groups =
    { lib, config, ... }:
    {
      home-manager.sharedModules = [
        (
          { lib, ... }:
          {
            options.userCfg.extraGroups = lib.mkOption {
              type = with lib.types; listOf str;
              default = [ ];
              description = "Groups this user wants to join; granted only if the group exists on the host.";
            };
          }
        )
      ];

      users.users = lib.mapAttrs (_name: hm: {
        extraGroups = builtins.filter (g: config.users.groups ? ${g}) hm.userCfg.extraGroups;
      }) config.home-manager.users;
    };
}
