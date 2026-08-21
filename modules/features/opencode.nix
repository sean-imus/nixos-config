{ pkgs, ... }:
{
  programs.opencode = {
    enable = true;
    tui = {
      theme = "everforest";
    };
    settings = {
      mcp = {
        nixos = {
          type = "local";
          command = [ "${pkgs.mcp-nixos}/bin/mcp-nixos" ];
        };
      };
    };
  };

  home.shellAliases = {
    c = "opencode --auto";
    ce = "opencode --auto --continue ~/nixos-config";
  };
}
