{ pkgs, inputs, ... }:
{
  programs.opencode = {
    enable = true;
    #TODO REMOVE WORKAROUND BELOW AND INPUTS INPUT
    package = inputs.opencode.packages.${pkgs.system}.default;
    tui = {
      theme = "system";
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
