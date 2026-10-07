{ lib, pkgs, ... }:
let
  # PostToolUse hook: keep edited Nix files in the repo's formatter style.
  # Never fails: a syntax error mid-edit must not block Claude.
  formatHook = pkgs.writeShellApplication {
    name = "claude-format-hook";
    runtimeInputs = [
      pkgs.jq
      pkgs.nixfmt
    ];
    text = ''
      file=$(jq -r '.tool_input.file_path // empty')
      case "$file" in
        *.nix) [ -f "$file" ] && nixfmt "$file" >/dev/null 2>&1 ;;
      esac
      exit 0
    '';
  };

  # Notification and Stop hooks -> desktop notification (shown by qs-shell).
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

  # statusLine command: Claude Code pipes session JSON in. Plan usage
  # (`rate_limits`, Pro/Max only, after the first response) is cached for the
  # quickshell bar; see README.md for the file contract.
  usageStatusLine = pkgs.writeShellApplication {
    name = "claude-usage-statusline";
    runtimeInputs = [
      pkgs.jq
      pkgs.coreutils
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
in
{
  programs.claude-code = {
    enable = true;
    enableMcpIntegration = true;

    # ~/.claude/settings.json is also written by Claude Code itself (/model,
    # /config, ...): declared keys are merged in, everything else is kept.
    mutableSettings = true;

    settings = {
      env.CLAUDE_CODE_SUBAGENT_MODEL = "haiku";

      statusLine = {
        type = "command";
        command = lib.getExe usageStatusLine;
      };

      hooks = {
        PostToolUse = [
          {
            matcher = "Write|Edit|MultiEdit";
            hooks = [
              {
                type = "command";
                command = lib.getExe formatHook;
              }
            ];
          }
        ];
        Notification = [
          {
            matcher = "permission_prompt|idle_prompt|elicitation_dialog";
            hooks = [
              {
                type = "command";
                command = lib.getExe notifyHook;
              }
            ];
          }
        ];
        Stop = [
          {
            hooks = [
              {
                type = "command";
                command = lib.getExe notifyHook;
              }
            ];
          }
        ];
      };
    };

    lspServers.nix = {
      command = lib.getExe pkgs.nixd;
      extensionToLanguage.".nix" = "nix";
    };
  };

  home.shellAliases.cc = "claude";
}
