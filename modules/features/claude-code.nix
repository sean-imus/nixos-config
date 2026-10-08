{ lib, pkgs, ... }:
let
  script = name: runtimeInputs: text: {
    type = "command";
    command = lib.getExe (pkgs.writeShellApplication { inherit name runtimeInputs text; });
  };

  statusLine = script "claude-usage-statusline" [ pkgs.jq ] ''
    input=$(cat)
    file="''${XDG_RUNTIME_DIR:-/tmp}/claude-usage.json"
    if jq -e '.rate_limits.five_hour' <<<"$input" >/dev/null 2>&1; then
      jq -c '{five_hour: .rate_limits.five_hour, seven_day: .rate_limits.seven_day, updated: (now | floor)}' \
        <<<"$input" >"$file.tmp" && mv "$file.tmp" "$file"
    fi
    jq -r '[
      (.rate_limits.five_hour.used_percentage // empty | "5h \(round)%"),
      (.rate_limits.seven_day.used_percentage // empty | "7d \(round)%")
    ] | join(" · ")' <<<"$input"
  '';

  nixHook =
    script "claude-nix-hook"
      [
        pkgs.jq
        pkgs.nixfmt
        pkgs.deadnix
        pkgs.statix
      ]
      ''
        file=$(jq -r '.tool_input.file_path // empty')
        case "$file" in
          *.nix) ;;
          *) exit 0 ;;
        esac
        [ -f "$file" ] || exit 0
        nixfmt "$file" >/dev/null 2>&1 || exit 0
        report=$(
          deadnix -o json "$file" | jq -r '.file as $f | .results[] | "\($f):\(.line):\(.column): deadnix: \(.message)"'
          statix check -o errfmt "$file" || true
        )
        if [ -n "$report" ]; then
          printf '%s\n' "$report" >&2
          exit 2
        fi
      '';
in
{
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "claude-code" ];

  home-manager.sharedModules = [
    {
      home.shellAliases.c = "claude";

      programs.mcp = {
        enable = true;
        servers.nixos.command = lib.getExe pkgs.mcp-nixos;
      };

      programs.claude-code = {
        enable = true;
        enableMcpIntegration = true;
        mutableSettings = true;

        settings = {
          env.CLAUDE_CODE_SUBAGENT_MODEL = "haiku";
          permissions.allow = [ "mcp__plugin_hm_nixos" ];
          inherit statusLine;
          hooks.PostToolUse = [
            {
              matcher = "Write|Edit|MultiEdit";
              hooks = [ nixHook ];
            }
          ];
        };

        lspServers.nix = {
          command = lib.getExe pkgs.nixd;
          extensionToLanguage.".nix" = "nix";
        };
      };
    }
  ];
}
