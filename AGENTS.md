# AGENTS.md — NixOS Config (agent reference, not user-facing)

Exhaustive internal reference for coding agents. Completeness over readability.
Read this fully before touching anything — the wiring has non-obvious rules and
several silent-failure footguns.

Last restructure: 2026-07-03 — moved from per-feature named modules + two user
files (`sean.nix` + `sean-desktop.nix`) to **self-registering role buckets**.

---

## 1. Stack

- **flake-parts** — module system for the flake itself.
- **vic/import-tree** — `flake.nix` is `mkFlake (import-tree ./modules)`; every
  `.nix` under `modules/` is auto-loaded as a flake-parts module.
- **vic/flake-file** — `flake.nix` is **generated** (`# DO-NOT-EDIT` header).
  Inputs are declared in modules via `flake-file.inputs` and materialized with
  `nix run .#write-flake`.
- **Dendritic pattern** — each file is an *aspect*: it contributes config for one
  concern across classes (`nixos`, `homeManager`). Files contributing the same
  `flake.modules.<class>.<name>` **merge automatically**. This merge is the
  entire basis of the bucket architecture (§3).

---

## 2. Registration vs activation (the two phases)

**Phase 1 — registration (automatic).** import-tree loads every file. Each file
writes into the catalog `flake.modules.<class>.<name>`. Registration is inert —
nothing is active until imported.

- import-tree **excludes any path containing `/_`** (e.g. `niri/_keybindings.nix`).
  Use `_` for helper files imported explicitly by a parent.
- **New/renamed/moved files must be `git add`-ed before eval.** Nix reads the git
  tree and *ignores untracked files*; it *does* see uncommitted modifications to
  already-tracked files. So: edit tracked file → visible immediately; create/move
  a file → invisible until `git add`. This is the #1 "why didn't my change take"
  cause. `git mv` counts as a new path → `git add`.

**Phase 2 — activation (manual).** Something must import a registered module.
Activation happens in exactly these places:

- `modules/nix/flake-parts.nix` `mkNixos` builds a `nixosConfiguration` from a
  host aspect.
- Host files (`modules/hosts/*.nix`) `imports = [ … ]` the mechanisms, the user,
  and the buckets/aspects that host runs.
- The user file (`modules/users/sean.nix`) sets `home-manager.users.sean.imports`.

import-tree solves registration completely; it can **not** decide *which* feature
belongs on *which* host/user — that is the human decision encoded in the Phase-2
import lists. Keep those lists small (that's what buckets are for).

---

## 3. Bucket architecture (THE core concept)

Leaf features do **not** get their own module name. They self-register into one of
three **role buckets** per class:

| Bucket | Class(es) | Members |
|---|---|---|
| `core` | homeManager | btop, fastfetch, git, shell, ssh, **sops** (HM half folded in) |
| `dev` | homeManager | neovim (nixvim), claude-code |
| `desktop` | homeManager **and** nixos | every `features/desktop/*` file |

A feature file just does:

```nix
{ ... }: {
  flake.modules.homeManager.desktop = { programs.foo.enable = true; };
  flake.modules.nixos.desktop = { services.foo.enable = true; };  # only if it needs a system half
}
```

Multiple files all set `flake.modules.homeManager.desktop` — they merge into one
module. **Adding a desktop feature = create the file, done. No wiring list to
update anywhere.** This is the whole point; do not reintroduce aggregator lists.

### Who imports the buckets (the wiring, memorize this)

The split is **user brings personal env, host brings machine capability**:

- **User file** (`sean.nix`) → `home-manager.users.sean.imports = [ sean core dev ]`
  (identity + the two always-on personal buckets). This file is **host-agnostic**.
- **Host** → `imports = [ … desktop … ]` (the nixos `desktop` bucket).
  `modules/features/desktop/profile.nix` adds
  `flake.modules.nixos.desktop.home-manager.sharedModules = [ homeManager.desktop ]`,
  so importing `desktop` on a host turns on the system desktop **and** gives every
  user on that host the desktop HM stack **in one import**. Desktop therefore
  **cannot be half-wired** — the old two-far-apart-lists footgun is gone.

Consequence: a headless host simply doesn't import `desktop`; its users still get
`core`+`dev`. A desktop host importing `desktop` gives *all* its users the desktop.

### Mechanisms stay NAMED (not buckets)

Cross-cutting machinery is imported explicitly by name, not bucketed:
`nixos.sops`, `nixos.disko`, `nixos.persistence`, `nixos.user-groups`,
`nixos.hostDefault`, `nixos.dns`, and the notebook-only `nixos.qemu` /
`nixos.tailscale` / `nixos.wifi`. Users are named aspects too: `nixos.sean` +
`homeManager.sean`.

Rule of thumb: **leaf feature → bucket. Reusable mechanism or per-host optional →
named aspect.**

### Full activation flow

```
mkNixos "x86_64-linux" "notebook"      (flake-parts.nix)
  → nixosConfigurations.notebook
      nixos.notebook (hosts/notebook.nix) imports:
        hostDefault, disko, persistence, user-groups   (mechanisms, every host)
        sean            → account + home-manager.users.sean.imports = [ sean core dev ]
        desktop         → system desktop  +  sharedModules pushes homeManager.desktop to ALL users
        qemu, tailscale, wifi     (notebook-only)
      + inline laptop hardware (graphics, power, kernel modules, niri outputs)
```

The VM is identical minus `qemu`/`tailscale`/`wifi`/laptop-hardware, plus
`diskoCfg.encrypt = false` and niri `mod-key = "Alt"`.

---

## 4. How to change things (recipes)

**Add a desktop app:** create `modules/features/desktop/<name>.nix` writing
`flake.modules.homeManager.desktop` (and `flake.modules.nixos.desktop` if it needs
a system half). `git add`. Done — both hosts get it.

**Add a core/dev tool:** same, writing `homeManager.core` / `homeManager.dev`.

**Add a notebook-only service:** create a **named** aspect
`flake.modules.nixos.<name>` and add `<name>` to `notebook.nix` imports (not vm).

**Add a per-user group for a service:** in the module that enables the service, add
`home-manager.sharedModules = [ { userCfg.extraGroups = [ "<group>" ]; } ]`. The
user-groups bridge maps it and drops it on hosts lacking the group (§6). Never put
group names in the user file except genuine identity (`wheel`).

**Add a new user `bob`:** copy `modules/users/sean.nix` → `bob.nix`, rename `sean`
→ `bob` everywhere (the nixos aspect name, `users.users.bob`, the HM identity
aspect, `home-manager.users.bob.imports`, git identity), add `sean_hashed_password`
→ `bob_hashed_password` (and add that secret to `secrets.yaml`). `git add`. Add
`bob` to a host's imports. On a desktop host bob automatically gets the desktop via
sharedModules. **Gotcha:** `nixos.sops` derives its NixOS age-key path from the
*first* HM user (`lib.head (attrNames …)`); with multiple users confirm that user's
`/persist/home/<user>/.keys/age.txt` holds the key, or set the path explicitly.

**Add a new host:** create `modules/hosts/<name>.nix` with
`flake.modules.nixos.<name> = { … }` (import hostDefault + disko + persistence +
user-groups + a user + whatever aspects/buckets) and
`flake.nixosConfigurations = inputs.self.lib.mkNixos "x86_64-linux" "<name>"`. Set
`diskoCfg`, `networking.hostName`, hardware. `git add`.

---

## 5. Module layout

```
modules/
├── nix/flake-parts.nix        ← entrypoint; mkNixos helper (injects HM + disko)
├── hosts/
│   ├── default.nix            ← hostDefault (base: locale, boot, nix, pkgs, zsh, NM group via sharedModules)
│   ├── notebook.nix           ← Intel laptop; encrypt=true; imports desktop+qemu+tailscale+wifi
│   └── vm.nix                 ← VM; encrypt=false; imports desktop only; Alt mod-key
├── users/
│   ├── default.nix            ← user-groups bridge (NOT a user)
│   └── sean.nix               ← the user: nixos account + HM identity; imports core+dev
├── features/
│   ├── core/                  ← btop, fastfetch, git, shell, ssh  → homeManager.core
│   ├── dev/                   ← neovim, claude                     → homeManager.dev
│   ├── desktop/               ← everything graphical → nixos.desktop / homeManager.desktop
│   │   ├── profile.nix        ← bridges nixos.desktop → all users' homeManager.desktop (sharedModules)
│   │   ├── niri/{default,_keybindings,_utilities}.nix
│   │   ├── browser/browser.nix, _start-page.html
│   │   └── application-launcher, bar, calc, discord, filesharing, games, gtk,
│   │       lockscreen, office-suite, printing, rdp-work, screencap, terminal,
│   │       wallpaper, wifi(nixos, notebook-only in practice)
│   ├── secrets/               ← sops.nix (homeManager.core HM half + nixos.sops named), secrets.yaml, .sops.yaml
│   ├── storage/               ← disko.nix (conditional encryption), persistence.nix (impermanence + persist bridge)
│   └── virtualization/        ← qemu.nix (named, notebook-only; attaches libvirtd group via sharedModules)
```

Note: directory names are **organizational only** — nothing reads them. A file's
bucket is set by the `flake.modules.<class>.<name>` it writes, not its path.
`git.nix` lives in `core/` because it's core; `wifi.nix` sits in `desktop/` but is
a notebook-only nixos aspect (path is cosmetic).

---

## 6. Bridges (persist, groups) — the "never name a user" convention

Two instances of one pattern: a feature writes a **user-agnostic request** into an
option; a NixOS-level bridge resolves it **per-user** by `mapAttrs`-ing over
`config.home-manager.users`. No feature ever hardcodes a username.

**Group bridge** (`modules/users/default.nix`):
- injects `userCfg.extraGroups` into every HM user (via `home-manager.sharedModules`),
- maps each user's request onto `users.users.<name>.extraGroups`, **filtered by
  groups that actually exist on the host**:
  ```nix
  users.users = lib.mapAttrs (_n: hm: {
    extraGroups = builtins.filter (g: config.users.groups ? ${g}) hm.userCfg.extraGroups;
  }) config.home-manager.users;
  ```
  The filter is the host-safety trick: `qemu` requests `libvirtd` unconditionally;
  on the notebook the group exists → user joins; on the vm it doesn't → silently
  dropped, no eval error, no per-host code.

Where each group request lives (service *enablement* is host/nixos-side; the
per-user *membership* rides `sharedModules` from the same module):
- `networkmanager` → `hostDefault` (co-located with `networking.networkmanager.enable`).
- `libvirtd` → `nixos.qemu`.
- `video` → `homeManager.desktop` (niri, owner of the backlight keybinds).

Verified: notebook sean groups = `[video networkmanager libvirtd wheel]`; vm sean =
`[video networkmanager wheel]`.

**Persist bridge** (`modules/features/storage/persistence.nix`):
- injects `persist.{files,directories}` into every HM user, defaults everyone to
  `~/persist`, and maps all users into `preservation.preserveAt."/persist".users.<name>`.
- Per-user paths → HM feature/user module sets `persist.files`/`persist.directories`
  (paths relative to `$HOME`, same entry shape as preservation: bare string or
  attrs with `configureParent`/`mode`).
- System paths → the owning nixos module extends
  `preservation.preserveAt."/persist".directories` directly (e.g. qemu preserves
  `/var/lib/libvirt/`), so the path only exists on hosts importing that feature.
- `persistence.nix` is the **mechanism only** — it must never enumerate feature
  paths.

Only non-regenerable state is persisted. sops *generated* keys under
`~/.keys/generated_keys/` are **not** persisted (sops-nix recreates them each
activation); the age key itself **is** (declared in `sops.nix` `persist.files`).

---

## 7. SOPS secrets

Two sops surfaces, one age key at `~/.keys/age.txt` (`ageKeyRelPath`, single source
in `sops.nix`):

- **HM surface** — folded into `flake.modules.homeManager.core` (sops is always-on;
  core features reference `config.sops.secrets.*.path` directly because they merge
  into the same module). Reads the key via `$HOME/${ageKeyRelPath}`.
- **NixOS surface** — `flake.modules.nixos.sops`, a **named** aspect imported
  explicitly by the modules that decrypt system secrets: the user account (login
  password, `neededForUsers`), `wifi`, `tailscale`. It reads the key from the raw
  `/persist/home/<user>/${ageKeyRelPath}` because `neededForUsers` decryption runs
  **before** the home bind-mount exists. The user is derived from
  `lib.head (builtins.attrNames config.home-manager.users)` (forcing only attr
  *names* is cheap and dodges the sops eval cycle) — never hardcoded.

Both surfaces must resolve to the **same physical file** or a key migration is
triggered (§ migration gotcha below).

- A module consuming `sops.secrets.*` on the NixOS side must
  `imports = [ inputs.self.modules.nixos.sops ]` itself (don't rely on another
  module having pulled it in). HM consumers get it for free via `core`.
- Consumers reference the provider's path (`config.sops.secrets.<name>.path`),
  never a restated literal.
- `secrets.yaml` is committed encrypted; `.sops.yaml` creation rule is anchored
  `(^|/)secrets\.yaml$` so it matches from any invocation directory.

**Add a secret:** add `sops.secrets."name" = { … };` (HM: in a core file; NixOS: in
`nixos.sops` or the consuming module), then
`nix run nixpkgs#sops -- modules/features/secrets/secrets.yaml`, rebuild.

**Rotate the age key (lost key / fresh install):**
```bash
nix shell nixpkgs#age -c age-keygen -o ~/.keys/age.txt
# update the recipient in .sops.yaml, then:
nix run nixpkgs#sops -- --rotate --age $(nix shell nixpkgs#age -c age-keygen -y ~/.keys/age.txt) \
  modules/features/secrets/secrets.yaml
```
Commit the re-encrypted file, rebuild.

**Moving a persisted secret's path (two-step live migration, can fail mid-switch):**
1. Place the file at the new `/persist` path **first** (NixOS sops reads it during
   activation to decrypt `neededForUsers`; missing → activation fails).
2. Expect the first `rbs` to fail `home-manager-sean.service` — HM restarts the
   user `sops-nix.service` before reloading the new unit, so it runs the stale unit
   pointing at the old path. Recover with
   `systemctl --user daemon-reload && systemctl --user restart sops-nix.service && rbs`,
   or just reboot.
3. Keep the old key on `/persist` until a clean reboot confirms login (previous
   boot generations still reference the old path — it's the rollback net).

---

## 8. Disk, encryption, impermanence

Impermanent root (tmpfs `/`) + persistent `/persist` and `/nix` on btrfs.

```
Disk (by-id)
├─ ESP (vfat, 1G, /boot)
├─ [encrypt=true]  luks→cryptroot → btrfs (@nix,@persist)   |  [encrypt=false] root → btrfs (@nix,@persist)
└─ [encrypt=true]  luks→cryptswap → swap                    |  [encrypt=false] swap → swap
/  → tmpfs (size=4G)
```

`modules/features/storage/disko.nix` exposes `diskoCfg.{device,swapSize,encrypt}`.
`encrypt` defaults **true**. When true the partition attr keys are `luks`/`cryptswap`
and content is wrapped in LUKS — **kept byte-identical to the pre-refactor layout**
so the live notebook is unaffected (verified: `/dev/mapper/cryptroot`, luks devices
`cryptroot`+`cryptswap`, partition keys `ESP/luks/cryptswap` unchanged). When false
(vm) the keys are `root`/`swap`, plain btrfs + plain swap, **no LUKS, no boot
passphrase** (verified: empty `boot.initrd.luks.devices`).

- disko generates all `fileSystems`, `boot.initrd.luks`, mount ordering — no
  `hardware-configuration.nix`, no UUIDs.
- LUKS passphrase (when enabled) is interactive: once at `disko` format, again at
  every boot's initrd prompt. No keyfile.
- `/nix` and `/persist` are `neededForBoot = true`.

---

## 9. Fresh install

`nixos-install` (not `disko-install` — the latter builds the whole closure on the
ISO; nixvim's closure is too big for typical ISO RAM).

```bash
nix-shell -p disko
sudo disko --mode disko --flake github:sean-imus/nixos-config#[notebook|vm]
# copy the age key BEFORE installing (sops needs it during activation):
#   disko leaves /persist at /mnt/persist
mkdir -p /mnt/persist/home/sean/.keys
cp /mnt/usb/keys.txt /mnt/persist/home/sean/.keys/age.txt && chmod 600 …/age.txt
sudo nixos-install --no-channel-copy --no-root-password --flake github:sean-imus/nixos-config#[notebook|vm]
```
Post-install: `git clone … ~/persist/nixos-config`; rebuild with `rbs`
(`hostCfg.flakePath` = `.` on notebook, remote default elsewhere).

A future custom installer/rescue ISO is designed (not built) in `ISO_PLAN.md`.

---

## 10. Per-topic gotchas

- **`options` forces `config`**: if a NixOS module declares top-level `options`,
  *all* config attrs must live in a `config = { … }` block (top level then only
  allows `imports`/`options`/`config`). `disko.nix`, `hostDefault`, `sean.nix`
  follow this.
- **HM `config` ≠ NixOS `config`**: inside an HM module (`{ pkgs, config, ... }`)
  you only see HM options. NixOS options (`networking.hostName`, etc.) are NOT
  there. Reach the flake-parts scope via the outer `{ inputs, ... }` closure.
- **`home.homeDirectory` has no default** — set it explicitly; use
  `config.home.username` (not `home.username`).
- **`inputs` via closure** — inner HM `let`/module blocks can use `inputs` from the
  file's outer `{ inputs, ... }` without re-passing it.
- **Ephemeral tooling** — run one-off tools with `nix run nixpkgs#<pkg> -- …` or
  `nix shell nixpkgs#<pkg>` instead of adding them to config for debugging.
- **niri portal**: ScreenCast/Screenshot need `xdg-desktop-portal-luminous` (not
  wlr/hyprland); use `config.niri` (writes `niri-portals.conf`) with
  `org.freedesktop.impl.portal.*` keys. Wrong backend/prefix silently matches
  nothing. Stale xdp after testing:
  `pkill -f "xdg-desktop-portal$"; systemctl --user start xdg-desktop-portal`.
- **Screen recording**: `wl-screenrec` speaks `ext-image-copy-capture-v1` natively
  (no portal). `screencap.nix` toggles via pidfile; codec `hevc` (VBR — low static
  bitrate is correct).
- **Waybar custom modules**: `"custom/<name>"` in settings, `#custom-<name>` in CSS.
  Instant refresh: `signal = N` + `interval = "once"`, then `pkill -RTMIN+N waybar`.
- **Wifi (`ensureProfiles`)**: `psk-flags = 1` is mandatory (agent-owned) or NM
  silently connects with no password. Secret `matchSetting`/`matchType` must be the
  **D-Bus** names (`802-11-wireless-security`/`802-11-wireless`), not nmcli aliases.
  Profiles are recreated each activation — not persisted. Open networks: omit
  `wifi-security` and the secret entry.
- **nixvim**: `programs.nixvim.enable` replaces `programs.neovim`; set
  `programs.nixvim.nixpkgs.source = inputs.nixpkgs` to silence the source warning.
  LSP servers at `plugins.lsp.servers.<name>`; pylsp closure is large. Dry-build to
  catch missing plugins/servers.
- **niri HM `programs.niri.enable` doesn't exist** — the compositor is enabled on
  the **NixOS** side (`nixos.desktop`); HM only carries `programs.niri.settings`.
- **`/var/lib/nixos` not persisted** — `list-generations` only shows the current
  session; harmless.

---

## 11. Commands & validation

| Command | Purpose |
|---|---|
| `nix flake check --no-build --no-eval-cache` | fresh eval; catches structural/eval errors |
| `nix eval .#nixosConfigurations.<h>.config.<path>` | spot-check a realized option |
| `nix build '.#nixosConfigurations.<h>.config.system.build.toplevel' --dry-run` | full eval; catches type mismatches / missing pkgs |
| `nix run .#write-flake` | regenerate `flake.nix` after `flake-file.inputs` change |
| `nix run .#write-lock` | regenerate `flake.lock` |

`flake check` alone misses option type mismatches — **any restructure needs a dry
build of BOTH hosts.** Because features merge into shared buckets, also spot-check
markers after structural changes: `home-manager.users.sean.programs.{niri.settings,
vesktop.enable,waybar.enable,firefox.enable,nixvim.enable,git.enable}`, sean's
`users.users.sean.extraGroups`, and (for disko changes) `boot.initrd.luks.devices`
+ `disko.devices.disk.main.content.partitions` attr names on both hosts.

The `warning: unknown flake output 'modules'` from `flake check` is expected
(flake-parts modules output isn't in the standard schema) — not an error.

## 12. Adding flake inputs

Declare in any module:
```nix
flake-file.inputs.my-input = { url = "github:owner/repo"; inputs.nixpkgs.follows = "nixpkgs"; };
```
then **`nix run .#write-flake`** to regenerate `flake.nix` before the input is
usable. (Feature modules already colocate their own inputs, e.g. niri, nixvim,
disko, sops-nix, preservation, firefox-addons, netpala.)

## 13. Commits

One commit per completed request (not per edit). Format
`<type>(<scope>): <desc>` — type ∈ feat/fix/refactor/chore/docs; lowercase
imperative desc naming the behavior/package changed. Only commit when the user
asks. Examples: `feat(dns): force Cloudflare DNS-over-TLS`,
`refactor(modules): self-registering role buckets`.
