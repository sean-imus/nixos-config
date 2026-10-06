{ ... }:
{
  programs.claude-code = {
    enable = true;
    enableMcpIntegration = true;
  };

  home.shellAliases.cc = "claude";
}
