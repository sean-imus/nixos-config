{ pkgs, ... }:
{
  programs.opencode = {
    enable = true;
    settings = {
      mcp = {
        nixos = {
          type = "local";
          command = [ "${pkgs.mcp-nixos}/bin/mcp-nixos" ];
        };
      };
    };
  };

  home.shellAliases.c = "opencode --auto";
}
