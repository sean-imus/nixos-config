# claude-code

Claude Code (Pro plan) for `sean`. Repo rules are in `AGENTS.md`.

## Layout

- `default.nix` — NixOS side: the unfree allowance for `claude-code`, and `home-manager.sharedModules = [ ./home.nix ]`.
- `home.nix` — home-manager side: `programs.claude-code`, the hook/statusLine scripts, the `cc` alias.

MCP servers are not declared here: `programs.claude-code.enableMcpIntegration` pulls them from `programs.mcp` (`features/mcp.nix`).

## Settings

`~/.claude/settings.json` is written by Claude Code too (`/model`, `/config`), so `mutableSettings = true`: the keys declared in `home.nix` are merged in on activation and replace the existing value; every other key (model, theme, ...) is left alone. Removing a declaration does not remove the key from the file; delete it by hand.

Declared today:

- `env.CLAUDE_CODE_SUBAGENT_MODEL = "haiku"` — subagents run on Haiku to stretch the Pro usage window.
- `statusLine` — `claude-usage-statusline` (see below).
- `hooks.PostToolUse` (`Write|Edit|MultiEdit`) — `claude-format-hook` runs `nixfmt` on edited `*.nix` files. Never fails the hook.
- `hooks.Notification` (permission/idle/elicitation prompts) and `hooks.Stop` — `claude-notify-hook` sends `notify-send -a claude-code`, shown by the qs-shell notification server.
- `lspServers.nix` — `nixd` for `.nix` files (shipped as a generated `hm` plugin).

## Usage file (contract with quickshell)

Claude Code pipes session JSON to the `statusLine` command. When it contains `rate_limits.five_hour` (Pro/Max only, and only after the session's first API response), the script writes

```json
{"five_hour":{"used_percentage":23.5,"resets_at":1738425600},"seven_day":{"used_percentage":41.2,"resets_at":1738857600},"updated":1738420000}
```

atomically (`tmp` + `mv`) to `$XDG_RUNTIME_DIR/claude-usage.json`. `quickshell/qml/services/ClaudeUsage.qml` polls it and the bar shows `CC <n>%` next to the workspaces (yellow, red from 90, grey `CC --` before the first session after boot).

- The file only updates while a Claude Code session is running. A window whose `resets_at` has passed is shown as 0%.
- If the field names in the statusLine JSON change, fix the `jq` in `home.nix` and the parser in `ClaudeUsage.qml` together.
