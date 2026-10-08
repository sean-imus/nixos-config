{ lib, pkgs, ... }:
let
  nixHook = pkgs.writeShellApplication {
    name = "claude-nix-hook";
    runtimeInputs = [
      pkgs.jq
      pkgs.nixfmt
      pkgs.deadnix
      pkgs.statix
    ];
    text = ''
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
  };

  notifyHook = pkgs.writeShellApplication {
    name = "claude-notify-hook";
    runtimeInputs = [
      pkgs.jq
      pkgs.libnotify
    ];
    text = ''
      body=$(jq -r 'if .hook_event_name == "Stop" then "Finished" else (.message // "Needs attention") end')
      notify-send -a claude-code "Claude Code" "$body"
    '';
  };

  usageStatusLine = pkgs.writeShellApplication {
    name = "claude-usage-statusline";
    runtimeInputs = [
      pkgs.jq
    ];
    text = ''
      input=$(cat)
      file="''${XDG_RUNTIME_DIR:-/tmp}/claude-usage.json"
      if jq -e '.rate_limits.five_hour' <<<"$input" >/dev/null 2>&1; then
        jq -c '{five_hour: .rate_limits.five_hour, seven_day: (.rate_limits.seven_day // null), updated: (now | floor)}' \
          <<<"$input" >"$file.tmp" && mv "$file.tmp" "$file"
      fi
      jq -r '[
        (.rate_limits.five_hour.used_percentage // empty | "5h \(round)%"),
        (.rate_limits.seven_day.used_percentage // empty | "7d \(round)%")
      ] | join(" · ")' <<<"$input"
    '';
  };

  cmd = pkg: {
    type = "command";
    command = lib.getExe pkg;
  };
in
{
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

      statusLine = cmd usageStatusLine;

      hooks = {
        PostToolUse = [
          {
            matcher = "Write|Edit|MultiEdit";
            hooks = [ (cmd nixHook) ];
          }
        ];
        Notification = [
          {
            matcher = "permission_prompt|idle_prompt|elicitation_dialog";
            hooks = [ (cmd notifyHook) ];
          }
        ];
        Stop = [ { hooks = [ (cmd notifyHook) ]; } ];
      };
    };

    lspServers.nix = {
      command = lib.getExe pkgs.nixd;
      extensionToLanguage.".nix" = "nix";
    };
  };

  home.shellAliases.cc = "claude";
}
