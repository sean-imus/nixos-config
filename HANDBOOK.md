# HANDBOOK — System Quick Reference

## System management

| Command | What it does |
|---------|-------------|
| `rbs` | `nixos-rebuild switch` — apply config changes live |
| `rbb` | `nixos-rebuild boot` — apply on next reboot (then reboots) |
| `sudo nixos-rebuild switch --flake .#notebook` | Same as `rbs` (explicit) |
| `sudo nixos-rebuild switch --flake .#vm` | Rebuild the VM config |
| `nix flake check --no-build --no-eval-cache` | Eval check — catches syntax/option errors |
| `nix build '.#nixosConfigurations.notebook.config.system.build.toplevel' --dry-run` | Dry build — catches type mismatches, missing packages |
| `nix run .#write-flake` | Regenerate `flake.nix` (only needed after adding a `flake-file.inputs`) |
| `nix run .#write-lock` | Regenerate `flake.lock` |

---

## One-off tools (no config change needed)

```bash
nix run nixpkgs#<package>         # run once and exit
nix shell nixpkgs#<package>       # available for the session
```

Examples:
```bash
nix run nixpkgs#sops -- modules/features/secrets/secrets.yaml
nix run nixpkgs#jq -- '.key' file.json
nix shell nixpkgs#age             # then: age-keygen ...
```

---

## Secrets (sops)

All secrets live in `modules/features/secrets/secrets.yaml` (encrypted, committed to git).
Age key: `~/.ssh/sops_age_key` (preserved from `/persist`, backed up on USB).

### Edit the secrets file

```bash
nix run nixpkgs#sops -- modules/features/secrets/secrets.yaml
```

Opens `$EDITOR` with decrypted contents. Save → sops re-encrypts automatically.

### Change your login password

```bash
mkpasswd             # prompts for password, prints $y$... hash
nix run nixpkgs#sops -- modules/features/secrets/secrets.yaml
# edit: sean_hashed_password: <new-hash>
rbs                  # apply; new password active immediately
```

### Add a new secret

1. Open secrets file, add `my_secret: value`, save.
2. Declare it in a NixOS or HM module (see AGENTS.md → SOPS secrets).
3. `rbs`

### View a secret without editing

```bash
nix run nixpkgs#sops -- --decrypt --extract '["secret_name"]' \
  modules/features/secrets/secrets.yaml
```

### Rotate the age key (key lost/compromised)

```bash
nix shell nixpkgs#age -c age-keygen -o ~/.ssh/sops_age_key
age-keygen -y ~/.ssh/sops_age_key   # → new public key
nix run nixpkgs#sops -- --rotate --age <new-public-key> \
  modules/features/secrets/secrets.yaml
# commit re-encrypted secrets.yaml, copy key to USB, rbs
```

---

## Desktop keybindings (Mod = Super/Win)

### Apps

| Key | Action |
|-----|--------|
| `Mod+T` | Terminal (alacritty) |
| `Mod+B` | Browser (qutebrowser) |
| `Mod+Space` | App launcher (fuzzel) |
| `XF86Calculator` | Python REPL (floating) |
| `Mod+Ctrl+B` | Bluetooth TUI (bluetui) |
| `Mod+Ctrl+A` | Audio mixer (wiremix) |
| `Mod+Ctrl+W` | Network (netpala) |
| `Mod+P` | Power menu |
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

### Screenshot

| Key | Action |
|-----|--------|
| `Mod+C` | Interactive screenshot |
| `Mod+Ctrl+C` | Screenshot screen |
| `Mod+Alt+C` | Screenshot window |
| `Mod+Ctrl+Shift+C` | Screen capture (video) |

### System

| Key | Action |
|-----|--------|
| `Super+Alt+L` | Lock screen |
| `Mod+Shift+Space` | Restart waybar |
| `Mod+Ctrl+Space` | Kill waybar |
| `Mod+Shift+E` | Quit niri |
| `Mod+Escape` | Toggle keyboard shortcuts inhibit (for games/nested compositors) |

---

## Persistence (what survives a reboot)

**Persists** (on `/persist`, LUKS-encrypted BTRFS):
- `/etc/NetworkManager/system-connections` — WiFi passwords
- `/etc/machine-id` — stable machine identity
- `~/.ssh/sops_age_key` — age decryption key
- `~/.local/state/wireplumber` — audio device preferences
- `~/persist/` — your personal files (bind-mounted from `/persist/home/sean/persist`)

**Ephemeral** (lost on reboot, tmpfs `/`):
- Everything else: downloads, browser cache, `/tmp`, shell history from other sessions, etc.

---

## WiFi passwords

Currently persisted on the encrypted `/persist` via NetworkManager — not in git, no sops needed.
They survive reboots automatically once you connect once.

If you want WiFi passwords declarative and in the repo (managed via sops), that's possible with
`networking.networkmanager.ensureProfiles` + sops secrets, but is a separate task.

---

## Fresh install (quick ref)

Full steps in AGENTS.md. In short:

```bash
# 1. Boot NixOS ISO, then:
nix-shell -p disko
sudo disko --mode disko --flake github:sean-imus/nixos-config#notebook

# 2. Copy age key from USB (CRITICAL — without this, boot fails)
mount /dev/sda1 /mnt/usb
mkdir -p /mnt/persist/home/sean/.ssh
cp /mnt/usb/sops_age_key /mnt/persist/home/sean/.ssh/sops_age_key
chmod 700 /mnt/persist/home/sean/.ssh && chmod 600 /mnt/persist/home/sean/.ssh/sops_age_key
umount /mnt/usb

# 3. Install
sudo nixos-install --no-channel-copy --no-root-password \
  --flake github:sean-imus/nixos-config#notebook
```
