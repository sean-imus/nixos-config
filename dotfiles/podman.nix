{ pkgs, config, ... }:

{
  # Podman setup
  services.podman = {
    enable = true;
  };
  


  # Install NixOS MCP
  home.packages = [ pkgs.mcp-nixos ];
}
