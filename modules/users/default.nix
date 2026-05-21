{ inputs, lib, ... }:
let
  inherit (lib) types mkOption mkIf;
in
{
  flake.modules.nixos.userDefault =
    { pkgs, config, ... }:
    let
      cfg = config.userCfg;
    in
    {
      options.userCfg = {
        userName = mkOption { type = types.str; };
        fullName = mkOption { type = types.str; };
        hashedPassword = mkOption { type = types.str; };
        extraGroups = mkOption {
          type = types.listOf types.str;
          default = [
            "networkmanager"
            "wheel"
          ];
        };
        shell = mkOption {
          type = types.package;
          default = pkgs.zsh;
        };
      };

      config = {
        users.users.${cfg.userName} = {
          isNormalUser = true;
          description = cfg.fullName;
          hashedPassword = cfg.hashedPassword;
          extraGroups = cfg.extraGroups;
          shell = cfg.shell;
        };

        programs.zsh.enable = true;

        nix.settings.trusted-users = [ cfg.userName ];

        home-manager.users.${cfg.userName} = {
          imports = [
            inputs.self.modules.homeManager.${cfg.userName}
          ];
        };
      };
    };

  flake.modules.homeManager.default =
    { config, ... }:
    let
      cfg = config.userCfg;
    in
    {
      options.userCfg = {
        userName = mkOption { type = types.str; };
        gitIdentity = mkOption {
          type = types.nullOr (
            types.submodule {
              options = {
                name = mkOption { type = types.str; };
                email = mkOption { type = types.str; };
              };
            }
          );
          default = null;
        };
        extraPackages = mkOption {
          type = types.listOf types.package;
          default = [ ];
        };
      };

      config = {
        home.username = cfg.userName;
        home.homeDirectory = "/home/${cfg.userName}";
        home.stateVersion = "25.11";

        programs.git.settings.user = mkIf (cfg.gitIdentity != null) cfg.gitIdentity;

        home.packages = cfg.extraPackages;
      };
    };
}
