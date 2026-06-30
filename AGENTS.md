# AGENTS.md — NixOS Config

Last updated: 2026-06-11

Single-machine NixOS config using the **Dendritic Design** pattern with **flake-parts**.

## Architecture

- **`flake.nix` is auto-generated** by `vic/flake-file`. Do not edit — header says `# DO-NOT-EDIT`. Regenerate with `nix run .#write-flake`.
- **All `.nix` files under `modules/` are auto-imported** by `vic/import-tree`. No manual `imports` list in `flake.nix`.
- **Files must be `git add`-ed** before flake evaluation sees them. Untracked files are invisible to Nix flake evaluation.
- **`import-tree` excludes** paths containing `/_` — use this prefix for helper files imported by a parent module (e.g. `_keybindings.nix`).

## Module Layout

```
modules/
├── nix/flake-parts.nix              ← framework entrypoint, mkNixos helper, nixosConfigurations
├── hosts/
│   ├── default.nix                  ← host defaults (hostDefault — timezone, locale, boot, networking, pkgs, zsh)
│   ├── notebook.nix                 ← Intel laptop (full desktop + dev)
│   └── vm.nix                       ← VM (desktop, no dev)
├── users/
│   └── sean.nix                     ← user module: NixOS account + HM imports (core + dev + desktop)
├── features/
│   ├── core/                        ← always-on user features: btop, fastfetch, git, shell, sops, ssh; system: dns (cloudflare DoT), tailscale
│   ├── desktop/                     ← desktop features
│   │   ├── niri/                    ← niri compositor split into sub-modules
│   │   │   ├── default.nix          ← core: NixOS module, input, layout, animations, window/layer rules
│   │   │   ├── _keybindings.nix     ← all keybindings (media keys, navigation, workspace, app launchers)
│   │   │   └── _utilities.nix       ← playerctld, hidden desktop entries, home packages + shell scripts
│   │   ├── application-launcher.nix ← fuzzel
│   │   ├── bar.nix                  ← waybar
│   │   ├── browser/browser.nix      ← qutebrowser
│   │   ├── discord.nix              ← vesktop
│   │   ├── filesharing.nix          ← localsend
│   │   ├── lockscreen.nix           ← hyprlock
│   │   ├── notifications.nix        ← mako
│   │   ├── office-suite.nix         ← libreoffice
│   │   ├── printing.nix             ← CUPS + SANE
│   │   ├── rdp-work.nix             ← RDP work network profile (user-specific, exception to feature rules)
│   │   └── terminal.nix             ← alacritty
│   ├── dev/                         ← dev tooling (always-on): neovim (nixvim), claude-code
│   ├── secrets/                     ← sops-nix + encrypted secrets
│   ├── storage/                     ← disko, persistence (impermanence)
│   └── virtualization/              ← qemu/libvirt
```

## Host ↔ User Import Flow

Each host imports `sean` (the NixOS user module). `sean.nix` then bridges into Home Manager:

```
Host (e.g. notebook.nix)
  └─ imports: sean-desktop (NixOS module)
       └─ imports: sean (NixOS module)
            └─ creates user account
            └─ home-manager.users.sean.imports:
                 ├─ core (always): btop, fastfetch, git, shell, sops, ssh
                 └─ dev (always): neovim, claude
       └─ home-manager.users.sean.imports:
            └─ desktop: niri, bar, browser, terminal, discord, etc.
```

- **Always on** (core): btop, fastfetch, git, shell, sops, ssh
- **Always on** (dev): neovim (nixvim), claude-code
- **Desktop** (imported via sean-desktop): niri, waybar, alacritty, qutebrowser, vesktop, localsend, libreoffice, hyprlock, fuzzel, mako, printing, rdp-work

## Feature Module Pattern

Each feature file declares aspects under `flake.modules.<class>.<name>`:
```nix
{ inputs, ... }: {
  flake.modules.nixos.<name>     = { ... };  # NixOS config (optional)
  flake.modules.homeManager.<name> = { ... }; # HM config (optional)
}
```

Features are **self-contained** — importing a feature module activates it. No `hostCfg.*.enable` toggles needed. The host's `imports` list is the gate.

Features must be **user-independent** — no hardcoded usernames, bookmarks, etc.
Exception: `rdp-work.nix` may contain user-specific data.
User-specific data (git identity, bookmarks, extra packages) goes in `users/<user>.nix`.

## User Modules

There is no shared user template. Each user is a self-contained pair:
`modules/users/sean.nix` (NixOS account + core/dev HM imports, sets `home.stateVersion`
inline) and `modules/users/sean-desktop.nix` (layers the desktop HM modules on top).
Hosts import `sean` or `sean-desktop` directly.

## Commits

Commit once per completed request — not after every file edit. When a user asks for a specific change, make all edits, verify the build, then commit as a single atomic unit.

### Format

```
<type>(<scope>): <short description>
```

- **type**: `feat`, `fix`, `refactor`, `chore`, `docs`
- **scope**: the feature or module area (e.g. `notebook`, `dns`, `lockscreen`, `filesharing`)
- **description**: lowercase, imperative, no period — describe *what* changed, not *why*

### Examples (from this repo)

```
feat(notebook): suspend-then-hibernate on lid close
feat(dns): force Cloudflare DNS-over-TLS system-wide
feat(filesharing): restrict localsend ports to tailscale
feat(lockscreen): replace swaylock with hyprlock
```

Keep the description concrete — name the package or behavior that changed, not the file.

## Key Commands

| Command | Purpose |
|---------|---------|
| `nix flake check --no-build` | Quick eval check (fine for small changes) |
| `nix flake check --no-build --no-eval-cache` | Force fresh eval (cache busting) |
| `nix build '.#nixosConfigurations.notebook.config.system.build.toplevel' --dry-run` | Dry build — **always verify big changes** with this |
| `nix run .#write-flake` | Regenerate `flake.nix` |
| `nix run .#write-lock` | Regenerate `flake.lock` |

Rule of thumb: `nix flake check` catches eval errors but misses option type mismatches and other deep issues. Any non-trivial change (restructuring, moving config, adding modules) needs a dry build.

## Gotchas

- **`options` forces `config = { ... }`**: If a NixOS module declares top-level `options`, all config attributes (`users`, `programs`, `home-manager`, etc.) must go inside a `config = { ... }` block. The top-level module can only have `imports`, `options`, and `config` — anything else throws.
- **HM `config` ≠ NixOS `config`**: HM module function args (`{ pkgs, config, ... }`) give HM-scoped config. NixOS options like `networking.hostName` are NOT available there. Use `inputs` via closure from the outer flake-parts module scope instead.
- **`home.homeDirectory` has no default**: Must be set explicitly. Use `config.home.username` not `home.username` (the latter is not a variable in scope).
- **`inputs` is available via closure**: The outer `{ inputs, ... }` function scope is accessible from inner HM module `let` blocks without passing it again.
- **New file gotcha**: Always `git add` new `.nix` files before testing — Nix reads from the git tree and ignores untracked files. This is only needed when a technically fresh file is added. Files that have existed before do not need to be added since git already sees them. Only freshly created files or files that got renamed / moved need this treatment.
- **Ephemeral programs**: Use `nix run nixpkgs#<program> -- [args]` to run a program not currently installed (e.g. `nix run nixpkgs#jq -- '.key' file.json`). No config change needed. This is useful when debugging needs to happen and certain debugging tools that would be helpful arent installed currently. Prefer running useful programs like this instead of finding inefficient solutions or solutions that wouldn't provide as much helpful information. nix run makes a program exist for only one execution. nix shell makes them available as long as the shell session exists.

## Adding flake inputs

Feature modules can declare their own flake inputs using `flake-file.inputs`:
```nix
{ inputs, ... }: {
  flake-file.inputs = {
    my-input = {
      url = "github:owner/repo";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
```

After adding a `flake-file.inputs` declaration, **you must run `nix run .#write-flake`** to regenerate `flake.nix` before the new input is available in evaluation.

## SOPS secrets

SSH private key and other secrets managed via **sops-nix** (HM module, `modules/features/secrets/sops.nix`).

### Architecture

- **Age key** lives at `~/.config/sops/age/keys.txt` (preserved via impermanence as a single file). Only this one file persists — sops provisions everything else.
- **Encrypted secrets** are in `modules/features/secrets/secrets.yaml`, committed to git with `sops` metadata.
- Decryption uses the age key on-disk at activation time. No machine/host keys involved.

### Adding a new secret

1. In `modules/features/secrets/sops.nix`, add an entry to `sops.secrets`:
   ```nix
   sops.secrets."my_secret_name" = {
     path = "${config.home.homeDirectory}/some/path";
     mode = "0600";
   };
   ```
2. Edit the encrypted file to add the key-value pair:
   ```bash
   nix run nixpkgs#sops -- modules/features/secrets/secrets.yaml
   ```
3. Rebuild.

### Updating a secret

```bash
nix run nixpkgs#sops -- modules/features/secrets/secrets.yaml
```
Edit the value, save — sops re-encrypts automatically. Rebuild to deploy.

### Rotating the age key

If the age key is lost (e.g. fresh install), generate a new one:
```bash
nix shell nixpkgs#age -c age-keygen -o ~/.config/sops/age/keys.txt
```
Get the public key, update `.sops.yaml`, then re-encrypt `secrets.yaml`:
```bash
sops --rotate --age $(nix shell nixpkgs#age -c age-keygen -y ~/.config/sops/age/keys.txt) \
  modules/features/secrets/secrets.yaml
```
Commit, rebuild.

### Fresh install bootstrap

The age key lives on a USB drive. See the **Fresh Install** section — copy it before `nixos-install`.

If the age key is **lost permanently**, generate a new one:
```bash
age-keygen -o ~/.config/sops/age/keys.txt
age-keygen -y ~/.config/sops/age/keys.txt   # prints public key → update the recipient in secrets.yaml
nix run nixpkgs#sops -- --rotate --age <new-public-key> modules/features/secrets/secrets.yaml
```
Commit the re-encrypted `secrets.yaml`, then follow the fresh install steps.

## Declarative WiFi (NM ensureProfiles)

Wi-Fi profiles are declared in `modules/features/desktop/wifi.nix` via `networking.networkmanager.ensureProfiles`. PSKs come from sops secrets injected by `nm-file-secret-agent` at connect time.

**Critical: `psk-flags = 1` is required.** Without it, NM expects the PSK inline in the keyfile, finds nothing, and silently connects with no password. `psk-flags = 1` (agent-owned) tells NM to ask the secret agent instead.

```nix
wifi-security = {
  key-mgmt = "wpa-psk";
  psk-flags = 1;  # must be set — tells NM to ask nm-file-secret-agent
};
```

The secrets entry pattern for WPA-PSK:
```nix
secrets.entries = [{
  file = config.sops.secrets.wifi_home_psk.path;
  key = "psk";
  matchId = "home-wifi";                    # must match connection.id in the profile
  matchSetting = "802-11-wireless-security"; # D-Bus name — NOT the nmcli alias "wifi-security"
  matchType = "802-11-wireless";             # D-Bus name — NOT the nmcli alias "wifi"
  trim = true;                              # strips trailing newline from the secret file
}];
```

**Gotcha: use D-Bus names, not nmcli aliases.** NM sends `settingName="802-11-wireless-security"` over D-Bus; `nm-file-secret-agent` does exact string matching against this. Using `"wifi-security"` or `"wifi"` silently fails — the agent logs `"no entries were configured that match the request"` and NM logs `"no secrets: No agents were available"`.

Open networks (no password): omit `wifi-security` entirely and add no secrets entry.

`key-mgmt = "wpa-psk"` negotiates the highest security the AP supports (WPA3/SAE if available, WPA2 otherwise). It does not lock to WPA2.

NM profiles are recreated on every activation — `/etc/NetworkManager/system-connections` does **not** need to be persisted.

## Waybar custom modules

Custom modules use `"custom/<name>"` in the settings and `#custom-<name>` in CSS (note: dash not slash).

For instant refresh on a user action (e.g. clicking cycles a value), use signals instead of polling:
- Set `signal = N` (1–9) in the module config and `interval = "once"` — the exec script runs at startup only
- After the action script changes state, call `pkill -RTMIN+N waybar` to trigger a re-run
- Each module should use a distinct signal number to avoid cross-module refreshes

Example (power profile widget, signal 9):
```nix
"custom/perf" = {
  exec = "perf-status";   # outputs {"text":"...","class":"..."}
  signal = 9;
  interval = "once";
  return-type = "json";
  on-click = "power-toggle";  # power-toggle ends with: pkill -RTMIN+9 waybar
};
```

## Neovim (nixvim)

Neovim is configured via **[nixvim](https://nix-community.github.io/nixvim)** (github:nix-community/nixvim), a fully declarative Neovim module system. The config lives in `modules/features/dev/neovim.nix`.

### Key nixvim options

- LSP servers are at `plugins.lsp.servers.<name>`. Dedicated nixvim modules exist for `pylsp` (very comprehensive — Jedi, pycodestyle, pyflakes, autopep8, yapf, flake8, pylint, mypy, black, ruff, etc.), `ccls`, `hls`, `rust-analyzer`, `svelte`. Every server from nvim-lspconfig is auto-generated.
- `nixd` settings are wrapped as `nixd = cfg;`. Configure formatting with `plugins.lsp.servers.nixd.settings.formatting.command = [ "nixfmt" ]`.
- `plugins.lsp.keymaps.lspBuf` and `plugins.lsp.keymaps.diagnostic` take `{ key = "action" }` attrsets (e.g. `{ K = "hover"; gd = "definition"; }`).
- Plugins with nixvim modules: `gitsigns`, `neo-tree` (file explorer), `lazygit`, `nvim-autopairs`, `which-key`, `lualine`, `treesitter`, `noice`, `snacks`, `conform-nvim`, etc.
- Falling back to raw Lua: use `extraConfigLua`, `extraConfigLuaPre`, or `extraConfigLuaPost`.
- `programs.nixvim.enable = true` replaces `programs.neovim`. Set `home.sessionVariables.EDITOR = "nvim"` for default editor behavior.
- Suppress nixpkgs source warning: `programs.nixvim.nixpkgs.source = inputs.nixpkgs;`

### Verification

After changes to nixvim config:
1. `nix flake check --no-build --no-eval-cache` — catches eval errors
2. `nix build '.#nixosConfigurations.notebook.config.system.build.toplevel' --dry-run` — catches option type mismatches and missing packages (LSP servers, plugins)
3. nixvim's pylsp module auto-wraps `python-lsp-server` with enabled plugin dependencies (autopep8, pycodestyle, etc.). The resulting package can be large due to Python dependency closure.

## Impermanence & Disko

This system uses **impermanent root** (tmpfs) with persistent state on a LUKS-encrypted BTRFS partition.

### Architecture

```
Disk (NVMe by-id)
├─ ESP (vfat, 1G, /boot)
└─ LUKS (cryptroot, 100%)
   └─ GPT (nested)
      ├─ swap (variable, set per-host via `diskoSwapSize`)
      └─ BTRFS (remaining)
         ├─ @nix (/nix)     ← compress=zstd, noatime
         └─ @persist (/persist) ← compress=zstd, noatime
```

- **`/`** → tmpfs (`size=4G`), everything ephemeral
- **Preservation** (nix-community/preservation) bind-mounts selected paths from `/persist` into the tmpfs root (system dirs) and home (user dirs)
- **No `hardware-configuration.nix`** — disko generates all `fileSystems`, `boot.initrd.luks`, and mount config. You never need UUIDs or filesystem entries.

### Relevant Files

| File | Purpose |
|------|---------|
| `modules/features/storage/disko.nix` | GPT + LUKS + nested GPT (swap + BTRFS subvols) + tmpfs root; parameterized `diskoConfigDevice` option |
| `modules/features/storage/persistence.nix` | Preservation config: /var/lib/systemd/timers, /var/lib/libvirt/, /etc/machine-id, user ~/.config/sops/age/keys.txt, ~/.local/state/wireplumber, ~/persist |
| `modules/hosts/notebook.nix` | Sets `diskoConfigDevice` to by-id NVMe path, imports disko + persistence |
| `modules/hosts/vm.nix` | Sets `diskoConfigDevice` to virtio path, imports disko + persistence |

### Fresh Install

**Why not `disko-install`?** `disko-install` builds the entire system closure on the ISO before writing to disk. Packages like nixvim have large closures that exceed typical ISO RAM/space. `nixos-install` builds directly on the target disk's Nix store, so only the ISO itself needs to fit in RAM.

```bash
# 1. Partition and format the target disk
nix-shell -p disko
sudo disko --mode disko --flake github:sean-imus/nixos-config#[notebook/vm]

# 2. Copy the sops age key from USB before installing
#    (sops-nix needs it during nixos-install activation to decrypt the password hash)
#    disko leaves /persist mounted at /mnt/persist
lsblk   # find your USB device, e.g. /dev/sda1
mkdir -p /mnt/usb
mount /dev/sda1 /mnt/usb   # adjust device name
mkdir -p /mnt/persist/home/sean/.config/sops/age
cp /mnt/usb/keys.txt /mnt/persist/home/sean/.config/sops/age/keys.txt
chmod 600 /mnt/persist/home/sean/.config/sops/age/keys.txt
umount /mnt/usb

# 3. Install (builds into /mnt/nix/store on the target disk)
sudo nixos-install --no-channel-copy --no-root-password --flake github:sean-imus/nixos-config#[notebook/vm]
```

**Install flow:**
1. `disko` prompts for LUKS password, partitions, formats, and mounts everything under `/mnt`
2. Age key copied from USB to `/mnt/persist/home/sean/.config/sops/age/keys.txt` — sops-nix reads this during activation to decrypt the password hash (via `neededForUsers`). Without it the install fails.
3. `nixos-install` builds the system closure directly into `/mnt/nix/store` and installs the bootloader

### Post-Install Workflow

```bash
# Clone config repo to persist dir (survives reboots via ~/persist bind-mount)
git clone git@github.com:sean-imus/nixos-config.git ~/persist/nixos-config

# Edit as user (no sudo needed for editing), then rebuild:
cd ~/persist/nixos-config
sudo nixos-rebuild switch --flake .#notebook    # or `rbs` alias
```

No `/etc/nixos` symlink needed — `--flake` accepts any path. `rbs` alias is defined per-host via `hostCfg.flakePath` — defaults to `github:sean-imus/nixos-config`, overridden to `"."` on notebooks for local flake evaluation.

### Gotchas

- **LUKS password entered twice**: once during `disko` (format), and at every boot (initrd prompt). No keyfile — fully interactive.
- **Disko handles ALL filesystem config** on every rebuild — `fileSystems`, `boot.initrd.luks`, mount ordering. UUIDs not needed. The by-id path is stable across reboots.
- **`/var/lib/nixos` not persisted** — nixos-rebuild generates a fresh profile chain each boot. Doesn't affect function, just means `list-generations` only shows current session.
- **Configs no longer depend on repo clone**: All file references use nix store paths (relative `./` paths in modules). Desktop configs work on first boot out of the box without cloning.
- **`~/persist/nixos-config` survives reboots** because `~/persist` is a bind-mount into `/persist/home/sean/persist`.
- **Commit before testing**: Nix reads from git tree. `git add` new `.nix` files, commit changes before `disko` or remote evaluation.
