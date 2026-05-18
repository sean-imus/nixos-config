{ ... }:
{
  flake.modules.homeManager.opencode = {
    home.shellAliases = {
      c = "opencode";
    };

    programs.opencode = {
      enable = true;
      enableMcpIntegration = true;
      settings = {
        autoupdate = false;
      };
      tui = {
        theme = "system";
      };
    };
  };
}
