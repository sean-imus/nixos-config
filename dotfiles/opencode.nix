{ pkgs, config, ... }:

{
  # Install NixOS MCP
  home.packages = [ pkgs.mcp-nixos ];

  # Install Opencode & Setup MCP integration
  programs.opencode = {
    enable = true;
    settings = {
      mcp = {
        "NixOS MCP" = {
          type = "local";
          command = [
            "opencode"
            "x"
            "mcp-nixos"
          ];
        };
      };
    };
  };
}
