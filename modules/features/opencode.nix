{ pkgs, inputs, ... }:
{
  programs.mcp = {
    enable = true;
    servers.nixos.command = "${pkgs.mcp-nixos}/bin/mcp-nixos";
  };

  programs.opencode = {
    enable = true;
    #TODO REMOVE WORKAROUND BELOW AND INPUTS INPUT
    package = inputs.opencode.packages.${pkgs.system}.default;
    enableMcpIntegration = true;
    tui = {
      theme = "system";
    };
  };

  home.shellAliases = {
    c = "opencode --auto";
    ce = "opencode --auto --continue ~/nixos-config";
  };
}
