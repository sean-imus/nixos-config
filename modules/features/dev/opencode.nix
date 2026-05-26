{ inputs, lib, ... }:
{
  flake.modules.nixos.opencode = { config, ... }: {
    options.userCfg.opencode.enable = lib.mkEnableOption "opencode AI coding assistant";
    config = lib.mkIf config.userCfg.opencode.enable {
      home-manager.users.sean.imports = [ inputs.self.modules.homeManager.opencode ];
    };
  };

  flake.modules.homeManager.opencode =
    { pkgs, ... }:
    {
      home.shellAliases = {
        c = "opencode";
      };

      programs.opencode = {
        enable = true;
        settings = {
          autoupdate = false;
          formatter = true;
          lsp = true;
          mcp = {
            nixos = {
              command = [ "${pkgs.mcp-nixos}/bin/mcp-nixos" ];
              enabled = true;
              type = "local";
            };
          };
        };
        tui = {
          theme = "system";
        };
      };

      home.packages = with pkgs; [
        nixd
      ];
    };
}
