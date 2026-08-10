{ ... }:
{
  flake.modules.nixos.group-bridge =
    { lib, config, ... }:
    {
      # Functionality that lets Home-Manager modules declare groups that a user needs
      home-manager.sharedModules = [
        (
          { ... }:
          {
            options.userCfg.extraGroups = lib.mkOption {
              type = with lib.types; listOf str;
              default = [ ];
            };
          }
        )
      ];

      # Safety net that only makes users join groups that exist on a host
      users.users = lib.mapAttrs (_name: hm: {
        extraGroups = builtins.filter (g: config.users.groups ? ${g}) hm.userCfg.extraGroups;
      }) config.home-manager.users;
    };
}
