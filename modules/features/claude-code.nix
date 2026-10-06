{ lib, ... }:
{
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "claude-code" ];

  home-manager.users.sean = {
    programs.claude-code = {
      enable = true;
      enableMcpIntegration = true;
    };

    home.shellAliases.cc = "claude";
  };
}
