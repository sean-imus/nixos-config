{ pkgs, ... }:

{
  nixosModule = { };

  homeManagerModule = {
    # Install Global MCP for Editors (VSCode, Opencode)
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
