# claude-code

Claude Code (Pro plan) for `sean`. Repo rules are in `AGENTS.md`.

`default.nix` is the NixOS side (unfree allowance, attaches `home.nix`); `home.nix` is the home-manager side. MCP servers are declared there in `programs.mcp` (the `nixos` server) and pulled in through `enableMcpIntegration`.

## Settings

`~/.claude/settings.json` is written by Claude Code too (`/model`, `/config`), so `mutableSettings = true`: the keys declared in `home.nix` are merged in on activation and replace the existing value; every other key (model, theme, ...) is left alone. Removing a declaration does not remove the key from the file; delete it by hand.

Declared today:

- `env.CLAUDE_CODE_SUBAGENT_MODEL = "haiku"` — subagents run on Haiku to stretch the Pro usage window.
- `permissions.allow = [ "mcp__plugin_hm_nixos" ]` — every tool of the `nixos` MCP server runs without a prompt. home-manager ships MCP servers inside its generated plugin named `hm`, so tool names are `mcp__plugin_hm_<server>__<tool>`. A new `programs.mcp.servers` entry needs its own rule. Arrays are replaced on merge, so this list overwrites a hand-added `permissions.allow`.
- `statusLine` — `claude-usage-statusline` (see below).
- `hooks.PostToolUse` (`Write|Edit|MultiEdit`) — `claude-nix-hook` runs `nixfmt` on edited `*.nix` files, then `deadnix` and `statix`. Findings go to stderr with exit 2, which Claude Code feeds back to Claude. Non-Nix files and `nixfmt` failures (syntax error mid-edit) exit 0 silently.
- `hooks.Notification` (permission/idle/elicitation prompts) and `hooks.Stop` — `claude-notify-hook` sends `notify-send -a claude-code`, shown by the qs-shell notification server.
- `lspServers.nix` — `nixd` for `.nix` files (shipped as a generated `hm` plugin). Its unused-definition diagnostics reach Claude only asynchronously and for touched files, so the hook is the reliable check.

## Usage file (contract with quickshell)

Claude Code pipes session JSON to the `statusLine` command. When it contains `rate_limits.five_hour` (Pro/Max only, and only after the session's first API response), the script writes

```json
{"five_hour":{"used_percentage":23.5,"resets_at":1738425600},"seven_day":{"used_percentage":41.2,"resets_at":1738857600},"updated":1738420000}
```

atomically (`tmp` + `mv`) to `$XDG_RUNTIME_DIR/claude-usage.json`. `quickshell/qml/services/ClaudeUsage.qml` polls it and the bar shows `CC <n>%` next to the workspaces (yellow, red from 90, grey `CC --` before the first session after boot).

- The file only updates while a Claude Code session is running. A window whose `resets_at` has passed is shown as 0%.
- If the field names in the statusLine JSON change, fix the `jq` in `home.nix` and the parser in `ClaudeUsage.qml` together.
