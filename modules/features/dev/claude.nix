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

        settings = {
          hooks = {
            PostToolUse = [
              {
                matcher = "Write|Edit";
                hooks = [
                  {
                    type = "command";
                    command = ''
                      jq -r '.tool_input.file_path // .tool_response.filePath' | {
                        read -r f
                        case "$f" in
                          *.nix) ${pkgs.nixfmt}/bin/nixfmt "$f" ;;
                          *.py)  ${pkgs.python3Packages.black}/bin/black "$f" ;;
                        esac
                      } 2>/dev/null || true
                    '';
                  }
                ];
              }
            ];
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
        jq
      ];
    };
}
