{ lib, ... }:
{
  # claude-code is unfree; useGlobalPkgs means home-manager's own
  # nixpkgs.config is ignored, so the allowance has to be set at the NixOS
  # level. This is therefore a NixOS module that wraps the home-manager config.
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "claude-code" ];

  home-manager.users.sean = {
    programs.claude-code = {
      enable = true;
      enableMcpIntegration = true;
    };

    home.shellAliases.cc = "claude";
  };
}
