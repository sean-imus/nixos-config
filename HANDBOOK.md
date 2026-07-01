# HANDBOOK — Daily Driver

My personal cheat-sheet for running this machine day to day. Install-from-scratch,
config authoring, secret rotation, and architecture live in `README.md` and `AGENTS.md`.

## Rebuild & apply

| Command | What it does |
|---------|-------------|
| `rbs` | `nixos-rebuild switch` — apply config changes now |
| `rbb` | `nixos-rebuild boot` — apply on next boot, then reboots |
| `sudo nixos-rebuild switch --flake .#notebook` | Explicit form (same as `rbs` on the laptop) |
| `sudo nixos-rebuild switch --flake .#vm` | Rebuild the VM config |

`rbs`/`rbb` target `<flakePath>#<hostname>`. On **notebook** `flakePath` is `.` (the local
checkout). On the **vm** it defaults to `github:sean-imus/nixos-config`, so there `rbs`
rebuilds from GitHub — commit/push first, or use the explicit `--flake .#vm` form.

## Everyday aliases

| Alias | Runs |
|-------|------|
| `rbs` / `rbb` | rebuild switch / boot (above) |
| `c` | `claude` |
| `n` | `nvim` |
| `lg` | `lazygit` |
| `ff` | `fastfetch` |
| `cl` | `clear` |

## Update packages

```bash
nix flake update      # bump all inputs (nixpkgs etc.) in flake.lock
rbs                   # rebuild onto the newer packages
```

Bumping a single input: `nix flake update <input>`. (`nix run .#write-lock` regenerates
the lock the same way; use `nix flake update` for the normal "get newer stuff" loop.)

## Rollback & generations

Bad rebuild? Recover by generation:

```bash
sudo nixos-rebuild switch --rollback        # switch to the previous generation now
sudo nixos-rebuild list-generations         # list generations with dates
```

At boot, the systemd-boot menu lists every generation — pick an older entry to boot it.

Free disk space (old generations pile up):

```bash
sudo nix-collect-garbage -d      # delete all but the current system generation
nix-collect-garbage -d           # same for the per-user profile
nix store gc                     # sweep unreferenced store paths
```

## Secrets (sops) — daily ops

Secrets live encrypted in `modules/features/secrets/secrets.yaml`.
Age key: `~/.keys/age.txt` (persisted on `/persist`, backed up on USB).

```bash
# Edit the secrets file ($EDITOR opens decrypted; save re-encrypts)
nix run nixpkgs#sops -- modules/features/secrets/secrets.yaml

# View one secret without editing
nix run nixpkgs#sops -- --decrypt --extract '["secret_name"]' \
  modules/features/secrets/secrets.yaml
```

Change login password:

```bash
mkpasswd                                              # prints a $y$... hash
nix run nixpkgs#sops -- modules/features/secrets/secrets.yaml   # set sean_hashed_password
rbs                                                   # active immediately
```

Adding a new secret / declaring it in a module / rotating the age key → `AGENTS.md`.

## Desktop keybindings (Mod = Super/Win)

### Apps

| Key | Action |
|-----|--------|
| `Mod+T` | Terminal (alacritty) |
| `Mod+B` | Browser (Firefox) |
| `Mod+Space` | App launcher (fuzzel) |
| `XF86Calculator` | Python REPL (floating) |
| `Mod+Ctrl+B` | Bluetooth TUI (bluetui) |
| `Mod+Ctrl+A` | Audio mixer (wiremix) |
| `Mod+Ctrl+W` | Network (netpala) |
| `Mod+P` | Cycle power profile (saver → balanced → performance) |
| `Mod+Y` | Clipboard history (fuzzel picker) |

### Window management

| Key | Action |
|-----|--------|
| `Mod+H/J/K/L` or arrows | Focus left/down/up/right |
| `Mod+Ctrl+H/J/K/L` | Move window left/down/up/right |
| `Mod+Shift+H/J/K/L` | Focus monitor |
| `Mod+Ctrl+Shift+H/J/K/L` | Move column to monitor |
| `Mod+1–9` | Switch workspace |
| `Mod+Ctrl+1–9` | Move column to workspace |
| `Mod+Q` | Close window |
| `Mod+F` | Maximize column |
| `Mod+Shift+F` | Fullscreen window |
| `Mod+V` | Toggle floating |
| `Mod+R` | Cycle column width preset |
| `Mod++/-` | Resize column ±10% |
| `Mod+,/.` | Consume/expel window (columns) |
| `Mod+O` | Toggle overview |

### Screenshot & recording

| Key | Action |
|-----|--------|
| `Mod+C` | Interactive screenshot |
| `Mod+Ctrl+C` | Screenshot screen |
| `Mod+Alt+C` | Screenshot window |
| `Mod+Ctrl+Shift+C` | Screen capture (video) — see below |

Screen capture toggles: first press → select a region, then pick audio yes/no; recording
starts. Press `Mod+Ctrl+Shift+C` again to stop. Clips land in `~/Recordings/` as `.mp4`.

### System

| Key | Action |
|-----|--------|
| `Super+Alt+L` | Lock screen |
| `Mod+Shift+Space` | Restart waybar |
| `Mod+Ctrl+Space` | Kill waybar |
| `Mod+Shift+E` | Quit niri |
| `Mod+Escape` | Toggle keyboard-shortcuts inhibit (games/nested compositors) |

## Persistence — what survives a reboot

Root `/` is tmpfs and wiped every boot. Only these are kept (on LUKS-encrypted BTRFS `/persist`):

- `/etc/machine-id` — stable machine identity
- `/var/lib/libvirt/` — VM definitions/disks
- `~/.keys/` — age key + generated SSH keys
- `~/.claude/` — Claude Code credentials, sessions, projects
- `~/persist/` — personal files (this repo lives here)

Everything else is ephemeral: downloads, caches, `/tmp`, per-device audio volumes, etc.
WiFi is **declarative** — SSIDs and sops-encrypted PSKs live in
`modules/features/desktop/wifi.nix`, so known networks connect automatically after a rebuild
(no per-machine WiFi state to persist).

## One-off tools (no config change)

```bash
nix run nixpkgs#<package>     # run once and exit
nix shell nixpkgs#<package>   # add to the current shell session
```
