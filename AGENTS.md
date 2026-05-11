# AGENTS.md — NixOS Config

Single-machine NixOS config using the **Dendritic Design** pattern with **flake-parts**.

## Architecture

- **`flake.nix` is auto-generated** by `vic/flake-file`. Do not edit — header says `# DO-NOT-EDIT`. Regenerate with `nix run .#write-flake`.
- **All `.nix` files under `modules/` are auto-imported** by `vic/import-tree`. No manual `imports` list in `flake.nix`.
- **Files must be `git add`-ed** before flake evaluation sees them. Untracked files are invisible to Nix flake evaluation.
- **`import-tree` excludes** paths containing `/_`.

## Module Layout

```
modules/
├── nix/flake-parts.nix  ← framework entrypoint, mkNixos helper, nixosConfigurations
├── hosts/<host>.nix     ← host feature (imports NixOS features, wires up HM users)
├── users/<user>.nix     ← user feature (imports HM features, owns user-specific data)
├── features/            ← self-contained, user-independent feature modules
├── system/              ← system-level types (system-default, system-essential)
└── features/desktop/    ← nested feature directory (niri + waybar)
```

## Import Chain

```
import-tree ./modules
  → nix/flake-parts.nix        (flake-parts + flake-file)
  → hosts/notebook.nix         (NixOS host config)
      → system/system-essential.nix  (boot, networking, pkgs)
          → system/system-default.nix  (timezone, locale, nix settings)
      → features/*             (NixOS aspects: printing, qemu, rdp-work, niri, firefox, vscode)
      → home-manager.users.sean → users/sean.nix  (user feature)
          → features/*         (HM aspects: alacritty, btop, firefox, git, mcp, neovim,
                                niri, opencode, printing, rdp-work, shell, ssh, vesktop, vscode)
          + user-specific: git identity, firefox bookmarks, packages
```

Host and user are **parallel** — the host's `home-manager.users.<name>.imports` bridges to the user module, but each independently selects its own features.

## Feature Module Pattern

Each feature file declares aspects under `flake.modules.<class>.<name>`:
```nix
{ inputs, ... }: {
  flake.modules.nixos.<name>     = { ... };  # NixOS config (optional)
  flake.modules.homeManager.<name> = { ... }; # HM config (optional)
}
```

Features must be **user-independent** — no hardcoded usernames, bookmarks, etc.
Exception: `rdp-work.nix` may contain user-specific data.
User-specific data (git identity, bookmarks, extra packages) goes in `users/<user>.nix`.

## Key Commands

| Command | Purpose |
|---------|---------|
| `nix flake check --no-build` | Quick eval check (fine for small changes) |
| `nix flake check --no-build --no-eval-cache` | Force fresh eval (cache busting) |
| `nix build '.#nixosConfigurations.notebook.config.system.build.toplevel' --dry-run` | Dry build — **always verify big changes** with this |

Rule of thumb: `nix flake check` catches eval errors but misses option type mismatches and other deep issues. Any non-trivial change (restructuring, moving config, adding modules) needs a dry build.
| `nix run .#write-flake` | Regenerate `flake.nix` |
| `nix run .#write-lock` | Regenerate `flake.lock` |
| `nix run .#write-inputs` | Regenerate input pin file |

## Gotchas

- **HM `config` ≠ NixOS `config`**: HM module function args (`{ pkgs, config, ... }`) give HM-scoped config. NixOS options like `networking.hostName` are NOT available there. Use `inputs` via closure from the outer flake-parts module scope instead.
- **`home.homeDirectory` has no default** for `stateVersion ≥ 20.09`. Must be set explicitly. Use `config.home.username` not `home.username` (the latter is not a variable in scope).
- **`inputs` is available via closure**: The outer `{ inputs, ... }` function scope is accessible from inner HM module `let` blocks without passing it again.
- **New file gotcha**: Always `git add` new `.nix` files before testing — Nix reads from the git tree and ignores untracked files.
