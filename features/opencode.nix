{ ... }:

{
  nixosModule = { };

  homeManagerModule = {
    # Setup Opencode Alias
    home.shellAliases = {
      c = "opencode";
    };

    # Install Opencode & Setup MCP integration
    programs.opencode = {
      enable = true;
      enableMcpIntegration = true;
      tui = {
        theme = "system";
      };
    };
  };
}
