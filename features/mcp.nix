{ pkgs, ... }:

{
  nixosModule = { };

  homeManagerModule = {
    programs.mcp = {
      enable = true;
      servers = {
        nixos = {
          command = "${pkgs.mcp-nixos}/bin/mcp-nixos";
        };
      };
    };
  };
}
