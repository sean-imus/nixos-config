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
├── nix/flake-parts.nix     ← framework entrypoint, mkNixos helper, nixosConfigurations
├── hosts/
│   ├── default.nix         ← merged host defaults (hostDefault — timezone, locale, boot, networking)
│   ├── notebook.nix        ← notebook host config
│   └── vm.nix              ← VM host config
├── users/
│   ├── default.nix         ← user template (userDefault NixOS + default HM, with home.stateVersion)
│   └── sean.nix            ← sean's user config (imports userDefault, handles all user config directly)
├── features/               ← self-contained, user-independent feature modules
└── features/desktop/       ← nested feature directory (niri + waybar)
```

## Import Chain

```
import-tree ./modules
  → nix/flake-parts.nix          (flake-parts + flake-file, mkNixos helper)
  → hosts/default.nix            (merged host defaults: timezone, locale, boot, networking, pkgs)
  → hosts/<host>.nix             (NixOS host config; notebook or vm)
      → features/*               (NixOS aspects: disko, impermanence, printing, qemu, rdp-work, niri)
      → users/sean.nix           (user feature, NixOS-level: user account + HM bridge)
          → users/default.nix    (user template: userDefault — creates user via userCfg options)
          → features/*           (NixOS aspects: localsend)
          → features/*           (HM aspects: alacritty, btop, firefox, git, mcp, niri, nixvim,
                                  opencode, printing, rdp-work, shell, sops, ssh, vesktop)
          + user-specific: git identity, firefox bookmarks, packages
```

Host and user are **parallel** — the host selects system features, the user module imports the user template (`userDefault`) and selects HM features. The user template bridges NixOS to HM via `home-manager.users.<name>.imports`.

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

## User Template Pattern

`modules/users/default.nix` provides a reusable user template with two modules:

- **`flake.modules.nixos.userDefault`** — NixOS-side: placeholder for future common user NixOS config.
- **`flake.modules.homeManager.default`** — HM-side: sets `home.stateVersion` as a project-wide default.

Individual user configs (e.g., `users/sean.nix`) import the template and handle all user-specific config directly — account creation, features, git identity, packages, bookmarks.

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
- **Ephemeral programs**: Use `nix run nixpkgs#<program> -- [args]` to run a program not currently installed (e.g. `nix run nixpkgs#jq -- '.key' file.json`). No config change needed.

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

SSH private key and other secrets managed via **sops-nix** (HM module, `modules/features/sops.nix`).

### Architecture

- **Age key** lives at `~/.ssh/sops_age_key` (preserved via impermanence as a single file). Only this one file persists — sops provisions everything else.
- **Encrypted secrets** are in `modules/secrets/secrets.yaml`, committed to git with `sops` metadata.
- Decryption uses the age key on-disk at activation time. No machine/host keys involved.

### Adding a new secret

1. In `modules/features/sops.nix`, add an entry to `sops.secrets`:
   ```nix
   sops.secrets."my_secret_name" = {
     path = "${config.home.homeDirectory}/some/path";
     mode = "0600";
   };
   ```
2. Edit the encrypted file to add the key-value pair:
   ```bash
   sops modules/secrets/secrets.yaml
   ```
3. Rebuild.

### Updating a secret

```bash
sops modules/secrets/secrets.yaml
```
Edit the value, save — sops re-encrypts automatically. Rebuild to deploy.

### Rotating the age key

If the age key is lost (e.g. fresh install), generate a new one:
```bash
nix shell nixpkgs#age -c age-keygen -o ~/.ssh/sops_age_key
```
Get the public key, update `.sops.yaml`, then re-encrypt `secrets.yaml`:
```bash
sops --rotate --age $(nix shell nixpkgs#age -c age-keygen -y ~/.ssh/sops_age_key) \
  modules/secrets/secrets.yaml
```
Commit, rebuild.

### Fresh install bootstrap

```bash
# Restore ~/.ssh/sops_age_key from backup, OR:
age-keygen -o ~/.ssh/sops_age_key &&              # generate new key
  age-keygen -y ~/.ssh/sops_age_key               # get public key → update .sops.yaml

# Re-encrypt secrets against the new key if needed, then:
sudo nixos-rebuild switch --flake .#notebook
```

Neovim is configured via **[nixvim](https://nix-community.github.io/nixvim)** (github:nix-community/nixvim), a fully declarative Neovim module system. The config lives in `modules/features/nixvim.nix`.

### Adding nixvim to a new host/user

1. **Declare the input**: `nixvim.nix` already declares `flake-file.inputs` for nixvim. If starting from scratch, add a similar block.
2. **Import the HM module**: In `users/<user>.nix`, add `inputs.nixvim.homeModules.nixvim` to `home-manager.users.<name>.imports` (after `inputs.self.modules.homeManager.<name>`).
3. **Regenerate flake.nix**: `nix run .#write-flake` and `git add` the result.

### Key nixvim options

- LSP servers are at `plugins.lsp.servers.<name>`. Dedicated nixvim modules exist for `pylsp` (very comprehensive — Jedi, pycodestyle, pyflakes, autopep8, yapf, flake8, pylint, mypy, black, ruff, etc.), `ccls`, `hls`, `rust-analyzer`, `svelte`. Every server from nvim-lspconfig is auto-generated.
- `nixd` settings are wrapped as `nixd = cfg;`. Configure formatting with `plugins.lsp.servers.nixd.settings.formatting.command = [ "nixpkgs-fmt" ]`.
- `plugins.lsp.keymaps.lspBuf` and `plugins.lsp.keymaps.diagnostic` take `{ key = "action" }` attrsets (e.g. `{ K = "hover"; gd = "definition"; }`).
- Plugins with nixvim modules: `gitsigns`, `neo-tree` (file explorer), `lazygit`, `nvim-autopairs`, `which-key`, `lualine`, `treesitter`, `noice`, etc.
- Falling back to raw Lua: use `extraConfigLua`, `extraConfigLuaPre`, or `extraConfigLuaPost`.
- `programs.nixvim.enable = true` replaces `programs.neovim`. Set `home.sessionVariables.EDITOR = "nvim"` for default editor behavior.

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
      ├─ swap (24G)      ← encrypted hibernation
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
| `modules/features/disko.nix` | GPT + LUKS + nested GPT (swap + BTRFS subvols) + tmpfs root; parameterized `diskoConfigDevice` option |
| `modules/features/impermanence.nix` | Preservation config: /etc/NetworkManager/system-connections, /var/lib/bluetooth, /var/lib/systemd/timers, machine-id, SSH host keys, user ~/.ssh/sops_age_key, ~/persist, wireplumber |
| `modules/hosts/notebook.nix` | Sets `diskoConfigDevice` to by-id NVMe path, imports disko + impermanence |

### Fresh Install (disko-install)

One command handles partitioning, formatting, mounting, and installation:

```bash
sudo nix run 'github:nix-community/disko/latest#disko-install' -- \
  --flake github:<user>/nixos-config#notebook \
  --disk main /dev/disk/by-id/<nvme-by-id> \
  --write-efi-boot-entries
```

**Flag explanations:**
- `--disk main <device>` — **required** by `install-cli.nix` (throws if missing). `main` is the disk attr name from `disko.nix`. Overrides the flake's device via `lib.mkVMOverride`.
- `--write-efi-boot-entries` — without this, disko-install forcibly sets `canTouchEfiVariables = false` (overriding your config), so systemd-boot won't write NVRAM entries and the system might not boot.
- Flake URL can be `github:` for remote or a local path.

**Install flow:**
1. Prompts for LUKS password (interactive, `cryptsetup` during disko format)
2. Partitions, formats, mounts everything
3. Runs `nixos-install --no-root-password --no-channel-copy`
4. Writes systemd-boot entry to NVRAM

### Post-Install Workflow

```bash
# Clone config repo to persist dir (survives reboots via ~/persist bind-mount)
git clone git@github.com:sean-imus/nixos-config.git ~/persist/nixos-config

# Edit as user (no sudo needed for editing), then rebuild:
cd ~/persist/nixos-config
sudo nixos-rebuild switch --flake .#notebook    # or `rbs` alias
```

No `/etc/nixos` symlink needed — `--flake` accepts any path. `rbs` alias (defined in `hosts/default.nix`) runs from current directory.

### Gotchas

- **LUKS password entered twice**: once during `disko-install` (format), and at every boot (initrd prompt). No keyfile — fully interactive.
- **Disko handles ALL filesystem config** on every rebuild — `fileSystems`, `boot.initrd.luks`, mount ordering. UUIDs not needed. The by-id path is stable across reboots.
- **`/var/lib/nixos` not persisted** — nixos-rebuild generates a fresh profile chain each boot. Doesn't affect function, just means `list-generations` only shows current session.
- **First boot timing**: Preservation runs before SSH via systemd ordering. SSH host keys are generated fresh into the `/persist` symlinks on first boot, then persist across reboots.
- **Configs no longer depend on repo clone**: All file references use nix store paths (relative `./` paths in modules). Desktop configs work on first boot out of the box without cloning.
- **`~/persist/nixos-config` survives reboots** because `~/persist` is a bind-mount into `/persist/home/sean/persist`.
- **Commit before testing**: Nix reads from git tree. `git add` new `.nix` files, commit changes before `disko-install` or remote evaluation.
- **Private repo**: set `NIX_CONFIG="access-tokens = github.com=<token>"` on live USB.
