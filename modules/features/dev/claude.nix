{ ... }:
{
  flake.modules.homeManager.claude =
    { pkgs, ... }:
    {
      home.shellAliases.c = "claude";

      programs.claude-code = {
        enable = true;

        mcpServers = {
          nixos = {
            type = "stdio";
            command = "${pkgs.mcp-nixos}/bin/mcp-nixos";
          };
        };

        lspServers = {
          python = {
            command = "${pkgs.pyright}/bin/pyright-langserver";
            args = [ "--stdio" ];
            extensionToLanguage = {
              ".py" = "python";
            };
          };
          nix = {
            command = "${pkgs.nixd}/bin/nixd";
            extensionToLanguage = {
              ".nix" = "nix";
            };
          };
        };
      };

      home.packages = with pkgs; [
        mcp-nixos
        pyright
        nixd
        nixfmt
        python3Packages.black
      ];
    };
}
