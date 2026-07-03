{ ... }:
{
  flake.modules.homeManager.dev =
    { pkgs, ... }:
    {
      home.shellAliases.c = "claude";

      home.sessionVariables.CLAUDE_CODE_NO_FLICKER = "1";

      # Survive the tmpfs wipe: auth + onboarding state (files) and history
      # (dirs). Everything else under ~/.claude is regenerated, so not persisted.
      persist.files = [
        {
          file = ".claude/.credentials.json";
          configureParent = true;
        }
        { file = ".claude.json"; }
      ];

      persist.directories = [
        { directory = ".claude/sessions"; }
        { directory = ".claude/projects"; }
      ];

      programs.claude-code = {
        enable = true;

        mcpServers = {
          nixos = {
            type = "stdio";
            command = "${pkgs.mcp-nixos}/bin/mcp-nixos";
          };
        };

        settings = {
          viewMode = "focus";

          # Auto-format files Claude writes: nixfmt for .nix, black for .py.
          hooks = {
            PostToolUse = [
              {
                matcher = "Write|Edit";
                hooks = [
                  {
                    type = "command";
                    command = ''
                      ${pkgs.jq}/bin/jq -r '.tool_input.file_path // .tool_response.filePath' | {
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
    };
}
