# ISO_PLAN.md — Custom NixOS Live ISO (installer + rescue toolbelt)

> **Status: research / design only.** Nothing in this document has been built or wired
> into the flake. It exists so you can decide whether to proceed and understand roughly
> what you'll get. No `modules/hosts/iso.nix`, no flake inputs, no config changes have
> been made.

This document designs a **custom NixOS live ISO built from this flake** that serves two
purposes:

1. **Installer** — boot it on a fresh machine and run one command to reproduce `notebook`
   or `vm` (partition with disko, bootstrap the age key, `nixos-install`).
2. **Rescue toolbelt** — boot it against a *broken* existing install to unlock the LUKS
   disk, mount the btrfs subvolumes, chroot/repair, roll back a generation, etc.

---

## Table of contents

1. [Findings from the codebase](#1-findings-from-the-codebase)
2. [Verified facts (nix MCP)](#2-verified-facts-nix-mcp)
3. [Approach options A / B / C + recommendation](#3-approach-options--recommendation)
4. [How it wires into this flake](#4-how-it-wires-into-this-flake)
5. [What the ISO looks like when booted](#5-what-the-iso-looks-like-when-booted)
6. [Baked-in tooling & aliases](#6-baked-in-tooling--aliases)
7. [The embedded install script (README automation)](#7-the-embedded-install-script)
8. [Expected ISO size — breakdown & honest range](#8-expected-iso-size)
9. [Build time & resource expectations](#9-build-time--resource-expectations)
10. [In-repo vs separate-repo trade-off](#10-in-repo-vs-separate-repo)
11. [Ordered implementation + QEMU test steps](#11-ordered-implementation--qemu-testing)
12. [Risks & gotchas](#12-risks--gotchas)
13. [Concrete nixpkgs option/module reference](#13-concrete-nixpkgs-reference)

---

## 1. Findings from the codebase

Key facts about how *this* flake is structured, which constrain the design:

- **Dendritic + import-tree.** Every `.nix` file under `modules/` is auto-imported by
  `vic/import-tree`. There is no manual `imports` list in `flake.nix`. A new module file is
  activated simply by existing under `modules/` — but **it must be `git add`-ed first**,
  because Nix flake evaluation reads from the git tree and ignores untracked files
  (`AGENTS.md` lines 10–11, 147). Files whose path contains `/_` are *excluded* from
  auto-import (used for helper files imported explicitly by a parent).

- **`flake.nix` is generated.** It carries a `# DO-NOT-EDIT` header and is produced by
  `vic/flake-file`. You never hand-edit it. New flake inputs are declared via
  `flake-file.inputs = { ... }` inside any module, then regenerated with
  `nix run .#write-flake` (`AGENTS.md` 150–164). **Option A below adds no inputs, so no
  `write-flake` run is required.**

- **Host build helper.** `modules/nix/flake-parts.nix` defines:
  ```nix
  flake.lib.mkNixos = system: name: {
    ${name} = inputs.nixpkgs.lib.nixosSystem {
      modules = [
        inputs.self.modules.nixos.${name}
        inputs.home-manager.nixosModules.home-manager
        inputs.disko.nixosModules.disko          # <-- pulls in the disko MODULE
        { nixpkgs.hostPlatform = system; }
      ];
    };
  };
  ```
  This helper **always injects the disko NixOS module**. For the ISO we do **not** want the
  disko module (that defines the *target machine's on-disk layout*); we want only the disko
  *CLI tool*. So the ISO must be built with a plain `nixpkgs.lib.nixosSystem` call, not
  `mkNixos`.

- **Module convention.** Feature modules expose `flake.modules.nixos.<name> = { ... }`.
  Host modules additionally set
  `flake.nixosConfigurations = inputs.self.lib.mkNixos "x86_64-linux" "<name>"`
  (see `modules/hosts/notebook.nix:131`, `modules/hosts/vm.nix:38`).

- **Disko module** (`modules/features/storage/disko.nix`) declares the real
  `disko.devices`, `fileSystems."/nix"|"/persist"` (`neededForBoot = true`), LUKS
  `cryptroot`/`cryptswap`, nested GPT, btrfs subvolumes, and a tmpfs `/`. It **requires**
  `diskoConfigDevice` and `diskoSwapSize` options to be set. Importing this into the ISO
  would (a) demand those options and (b) collide with the ISO's own read-only squashfs
  filesystem layout. **Do not import it into the ISO.**

- **Persistence module** (`modules/features/storage/persistence.nix`) is the
  impermanence/preservation mechanism. A live ISO is a throwaway RAM environment — none of
  the `persist.*` machinery applies. **Do not import it into the ISO.**

- **README install steps** (README.md 77–94; mirrored in `AGENTS.md` 429–447) are exactly:
  1. `nix-shell -p disko`
  2. `sudo disko --mode disko --flake github:sean-imus/nixos-config#[notebook|vm]`
  3. Copy the sops age key from a USB stick to
     `/mnt/persist/home/sean/.keys/age.txt`, `chmod 600`
     (sops-nix needs it *during* `nixos-install` activation to decrypt the login password
     hash via `neededForUsers` — without it the install fails).
  4. `sudo nixos-install --no-channel-copy --no-root-password --flake …#[notebook|vm]`

  The install script (§7) automates precisely this sequence.

- **`hostDefault` package baseline** (`modules/hosts/default.nix:119–129`) already curates a
  sensible system package set — `lm_sensors pciutils usbutils iotop wget tldr bat zsh
  ncdu`. The ISO toolbelt mirrors and extends this so the rescue shell feels like the
  installed system.

- **QEMU.** `modules/features/virtualization/qemu.nix` provides libvirt/virt-manager on the
  *installed* host. It is **not** used for testing the ISO — ISO boot-testing uses ad-hoc
  `pkgs.qemu` + OVMF (see §11).

- **Repo source is tiny.** `git ls-files` = 49 tracked files; working tree (excl. `.git`) is
  ~500 KB. This matters for §8: embedding the flake *source* into the ISO costs essentially
  nothing. Embedding the built *closure* of a target host is an entirely different, much
  larger proposition.

---

## 2. Verified facts (nix MCP)

Checked live against nixpkgs unstable via the nix MCP server:

| Thing | Result |
|---|---|
| `nixos-generators` | package present, **v1.8.0** (the Option B route) |
| `nixos-install-tools` | present, **26.05pre-git** — so unstable is now on the 26.05 cycle; packages `nixos-install`, `nixos-generate-config`, `nixos-enter` for the toolbelt |
| `disko` CLI | present, **v1.13.0** (already a flake input in `flake.nix:7`) |
| `isoImage.*` options / `installer/cd-dvd/*.nix` | **not indexed** by search.nixos.org — these are *conditional profile modules*, only present when imported, so the options API returns nothing for them. They are long-standing, stable nixpkgs modules; reference them via `modulesPath` (see §13). |

> The `isoImage.*` options not being searchable is expected, not a red flag: search.nixos.org
> only indexes options that are unconditionally in the module tree. Installer profile options
> only materialize once you import `installation-cd-*.nix`.

---

## 3. Approach options & recommendation

### Option A — plain `nixosSystem` + nixpkgs installer profile, **in this flake** ✅ RECOMMENDED

Add one module that builds a `nixosConfiguration` importing
`installer/cd-dvd/installation-cd-minimal.nix`. The build output is
`config.system.build.isoImage`.

- **Pros:** zero new flake inputs; reuses the existing nixpkgs pin and `flake.lock`; idiomatic
  NixOS; trivially embeds `inputs.self` (the whole config source) into the ISO for an
  offline-friendly install; fits the dendritic file-per-module convention with the least
  ceremony. No `write-flake` round-trip needed.
- **Cons:** you write a little installer glue yourself (but it's ~40 lines).

### Option B — `nixos-generators` flake input (`format = "install-iso"`)

Add `nixos-generators` as an input; use
`inputs.nixos-generators.nixosGenerate { format = "install-iso"; modules = [ … ]; }`.

- **Pros:** one-liner to *also* emit other formats later (qcow2, vbox, sd-image, raw) from the
  same module set.
- **Cons:** buys nothing over Option A for a single ISO — `install-iso` is a thin wrapper over
  the very same `installation-cd` modules. Adds an input + a `write-flake` regeneration + an
  extra thing tracking upstream. Only worth it if you genuinely want a *matrix* of image
  formats.

### Option C — separate repo

A standalone flake that pulls this config in as an input.

- **Pros:** clean separation; could publish generic rescue-ISO release artifacts without
  touching this repo's history.
- **Cons:** duplicates the flake-parts scaffolding; second `flake.lock` to keep in sync;
  loses trivial `inputs.self` embedding (you'd embed a pinned external input instead, which
  can drift). Overkill for one personal ISO.

### Recommendation

**Option A, in this repo.** It reuses the existing pin and conventions, needs no new inputs,
and lets the ISO carry the config source for offline installs. Revisit Option B only if you
later want multiple image formats; revisit Option C only if you want to distribute a
config-agnostic rescue ISO. See §10 for the fuller in-repo vs separate-repo argument.

---

## 4. How it wires into this flake

*(Sketch only — not applied. Presented so the later implementation is unambiguous.)*

Create **`modules/hosts/iso.nix`**, a new "host" analogous to `notebook.nix` / `vm.nix`.
Crucially, build it with a **direct `nixpkgs.lib.nixosSystem`** call — **not** `mkNixos`,
which would force-import the disko module and demand `diskoConfigDevice`.

```nix
{ inputs, ... }:
let
  system = "x86_64-linux";
in
{
  # (1) The ISO's NixOS config, exposed as a module for inspection/reuse.
  flake.modules.nixos.installer-iso =
    { pkgs, modulesPath, lib, ... }:
    {
      imports = [
        (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
        # Intentionally NOT: self.modules.nixos.disko / persistence
        # (those describe the TARGET's on-disk layout, not the live ISO).
      ];

      isoImage.isoName            = lib.mkForce "nixos-config-installer.iso";
      isoImage.squashfsCompression = "zstd -Xcompression-level 6"; # tune per §9
      isoImage.makeEfiBootable    = true;
      isoImage.makeUsbBootable    = true;

      nixpkgs.hostPlatform = system;
      networking.hostName  = "installer";
      nix.settings.experimental-features = [ "nix-command" "flakes" ];

      # Embed THIS flake so installs can resolve `#notebook` / `#vm`
      # without cloning. `inputs.self` is ~500 KB of source (negligible).
      nix.registry.nixos-config.flake = inputs.self;
      environment.etc."nixos-config".source = inputs.self;

      environment.systemPackages = [ /* see §6 */ ];
      environment.shellAliases   = { /* see §6 */ };
      # nixos-config-install script -> §7
    };

  # (2) The buildable nixosConfiguration.
  flake.nixosConfigurations.iso = inputs.nixpkgs.lib.nixosSystem {
    modules = [ inputs.self.modules.nixos.installer-iso ];
  };

  # (3) Convenience package output so `nix build .#iso` works.
  perSystem = { ... }: {
    packages.iso =
      inputs.self.nixosConfigurations.iso.config.system.build.isoImage;
  };
}
```

**Build commands (once implemented):**

```bash
# via the packages output
nix build .#iso

# or the always-works toplevel form (mirrors AGENTS.md's dry-build pattern)
nix build '.#nixosConfigurations.iso.config.system.build.isoImage'
```

Output lands at `result/iso/nixos-config-installer.iso`.

If you later want the install script in its own file, name it
`modules/hosts/_iso-install.nix` (the `_` prefix keeps import-tree from auto-importing it)
and import it explicitly from `iso.nix`.

> **Reminder:** after creating the file, `git add modules/hosts/iso.nix` **before**
> `nix build`, or flake evaluation won't see it.

---

## 5. What the ISO looks like when booted

Here is the actual boot/login experience the design produces.

**Boot menu.** The `installation-cd` profile ships an isolinux/GRUB boot menu (BIOS) and an
EFI boot entry (because `isoImage.makeEfiBootable = true`). Default entry boots the live
system into RAM. On real hardware you `dd` the ISO to a USB stick (it's a hybrid ISO;
`makeUsbBootable = true` makes it work as a raw USB image).

**Login.** The minimal installer profile auto-logs-in a passwordless user named `nixos` with
sudo rights and drops you at a **plain TTY console shell** (no display manager, no desktop —
this is `installation-cd-minimal`, not the graphical Calamares ISO). If we set
`programs.zsh.enable = true` you land in zsh; otherwise bash. There's a friendly MOTD from the
installer profile. Networking comes up via NetworkManager (or `wpa_supplicant`/`iwd`); for
Wi-Fi you'd use `nmtui`.

**First impression / "toolbelt feel".** Because we mirror the installed system's package set
(§6), the rescue shell feels familiar: `bat`, `btop`, `ncdu`, `git`, `neovim`, `tmux`, `jq`,
`tldr` are all on `PATH`, plus the disk/crypto/install tooling. `/etc/nixos-config` contains
the full flake source (browsable, editable). The flake registry alias `nixos-config` resolves
to it, so `nixos-install --flake nixos-config#notebook` and
`nixos-rebuild --flake nixos-config#…` Just Work without a clone.

**Aliases available at the prompt** (see §6 for the full list). The headline ones:

- `install-notebook` / `install-vm` — run the guided installer (§7).
- `mount-persist` — replay the disko layout in *mount* mode against an existing install
  (prompts for the LUKS passphrase, mounts `/nix` + `/persist` + ESP under `/mnt`) for repair.
- `unmount-all` — tear the above back down (`umount -R /mnt`, close LUKS mappings).

**What `install-notebook` does, step by step, from the user's seat:**

1. You type `install-notebook` (alias for `sudo nixos-config-install notebook`).
2. It prints the **target disk** (`notebook`'s `diskoConfigDevice`, the by-id NVMe path) and
   a bright **"THIS WIPES THE ENTIRE DISK"** warning, then waits for you to type `yes`.
3. It runs `disko --mode disko --flake nixos-config#notebook`. Disko **prompts for a new LUKS
   passphrase**, partitions, formats (ESP vfat, LUKS→btrfs `@nix`/`@persist`, encrypted swap),
   and leaves everything mounted under `/mnt` (with `/persist` at `/mnt/persist`).
4. It runs the **age-key bootstrap**: shows `lsblk`, asks you to pick the USB partition holding
   `keys.txt`, mounts it, copies it to `/mnt/persist/home/sean/.keys/age.txt`, `chmod 600`,
   `chown`, unmounts the USB. If the key is missing it **aborts loudly** (activation would
   otherwise fail decrypting the login password). It offers a fallback path to generate a fresh
   age key + re-encrypt secrets (per `AGENTS.md` 216–221) for a truly-lost-key scenario.
5. It runs `nixos-install --no-channel-copy --no-root-password --flake nixos-config#notebook`.
   This builds the notebook closure into `/mnt/nix/store` (fetching from `cache.nixos.org` and
   any configured substituters) and installs systemd-boot. This is the slow part — expect
   several minutes to tens of minutes depending on cache hit rate and network.
6. It prints post-install next steps: reboot, unlock LUKS at the initrd prompt, then
   `git clone git@github.com:sean-imus/nixos-config.git ~/persist/nixos-config` and use `rbs`.

The whole thing is a **checklist-with-guardrails**, not a silent one-shot — each step is echoed,
destructive actions require confirmation, and it runs under `set -euo pipefail`.

---

## 6. Baked-in tooling & aliases

### `environment.systemPackages`

The `installation-cd-minimal` base already ships `nix`, a minimal `git`, and `openssh`. Add:

**Partition / install core**
- `disko` — use `inputs.disko.packages.${system}.disko` (disko is *already* an input,
  `flake.nix:7`), so the ISO uses the exact pinned version (v1.13.0)
- `nixos-install-tools` — `nixos-install`, `nixos-generate-config`, `nixos-enter`
- `parted`, `gptfdisk`, `cryptsetup`, `btrfs-progs`, `dosfstools`, `e2fsprogs`

**Secrets bootstrap**
- `age`, `sops` — inspect/rotate the age key, re-encrypt `secrets.yaml` if lost
  (`AGENTS.md` 201–221)

**Repo & editing**
- full `git`, `gh`, `neovim` (or `vim`), `tmux`

**Network / rescue**
- `networkmanager` (`nmtui`/`nmcli`), `iproute2`, `iw`, `wpa_supplicant`, `curl`, `wget`,
  `rsync`, `tailscale` (matches the config's stack), `ethtool`

**Diagnostics / QoL** (mirrors `hostDefault`, `modules/hosts/default.nix:119–129`)
- `pciutils`, `usbutils`, `lm_sensors`, `smartmontools`, `ncdu`, `htop`/`btop`, `bat`,
  `jq`, `tree`, `file`, `tldr`

### `environment.shellAliases`

```nix
environment.shellAliases = {
  install-notebook = "sudo nixos-config-install notebook";
  install-vm       = "sudo nixos-config-install vm";

  # Repair an existing install: replay layout in mount mode, prompts for LUKS pass.
  mount-persist = "disko --mode mount --flake /etc/nixos-config#notebook";

  # Tear the rescue mount back down.
  unmount-all = "umount -R /mnt 2>/dev/null; cryptsetup close cryptroot 2>/dev/null; cryptsetup close cryptswap 2>/dev/null; true";
};
```

Optionally set `programs.zsh.enable = true;` so the shell matches the installed system, and
rely on the installer profile's existing auto-login.

---

## 7. The embedded install script

Ship a `pkgs.writeShellApplication` named **`nixos-config-install`** (added to
`systemPackages`) that automates README.md 77–94. It takes the host as `$1`
(`notebook` | `vm`). Behavior:

1. **Validate arg** is `notebook` or `vm`. Set `FLAKE="/etc/nixos-config#$HOST"` (the embedded
   copy). Support a `--remote` flag that switches to
   `github:sean-imus/nixos-config#$HOST` instead.
2. **Confirm destruction.** Print the host's `diskoConfigDevice` and require an explicit typed
   `yes` — "this wipes the entire target disk".
3. **Partition/format:** `disko --mode disko --flake "$FLAKE"` (prompts for the LUKS
   passphrase; leaves `/persist` mounted at `/mnt/persist`).
4. **Age-key bootstrap (the critical step):** show `lsblk`; prompt for the USB partition;
   `mount` it; `mkdir -p /mnt/persist/home/sean/.keys`; `cp <usb>/keys.txt
   /mnt/persist/home/sean/.keys/age.txt`; `chmod 600`; `chown`; `umount`. Abort if the key is
   absent (sops-nix needs it during activation to decrypt the login password via
   `neededForUsers`, `AGENTS.md` 434–451). Offer an interactive fallback to generate a fresh
   age key + re-encrypt (`AGENTS.md` 216–221).
5. **Install:** `nixos-install --no-channel-copy --no-root-password --flake "$FLAKE"`.
6. **Post-install hint:** print the `git clone … ~/persist/nixos-config` + `rbs` next steps
   (README/`AGENTS.md` 456–465).

Because `/etc/nixos-config` is the embedded `inputs.self`, steps 3 and 5 don't need to clone
the repo and use the exact locked inputs from `flake.lock`. (They still fetch the *built
closure* from a binary cache over the network — see §8 for why that closure isn't baked in.)

Guardrails: `set -euo pipefail`, every step echoed, confirmations before anything destructive,
clear abort messages.

---

## 8. Expected ISO size

Two very different designs, and it's important to be honest about which one you pick:

### Design 1 — embed flake **source** only (RECOMMENDED, what §4 sketches)

The ISO carries the ~500 KB flake *source* (registry pin + `/etc/nixos-config`) but **not** the
built closure of `notebook`/`vm`. Installs still fetch the target closure from
`cache.nixos.org` at install time — which is exactly what `nixos-install` does anyway.

Size drivers:

| Component | Uncompressed store contribution (approx.) |
|---|---|
| `installation-cd-minimal` base (kernel, initrd, systemd, nix, coreutils, openssh, perl for the installer, firmware if enabled) | ~1.6–2.2 GB store closure |
| Toolbelt additions (§6): disko, nixos-install-tools, cryptsetup, btrfs-progs, parted, neovim, git+gh, tmux, networkmanager, tailscale, sops+age, btop/bat/jq/ncdu/tldr, smartmontools, etc. | ~+0.6–1.2 GB store closure |
| Embedded flake **source** (`inputs.self`, ~500 KB) | negligible |

That store tree is packed into a **squashfs** with zstd. Squashfs+zstd on a NixOS store
typically compresses to roughly **~35–45%** of the uncompressed size. So:

- **Realistic ISO size: ~1.2–1.8 GB**, most likely **~1.4 GB**.
- For comparison, the stock upstream `installation-cd-minimal` ISO is currently ~1.1–1.3 GB;
  our toolbelt adds a few hundred MB on top after compression.

Note: `nerd-fonts.jetbrains-mono` from `hostDefault` is *not* pulled in unless you import that
module — the ISO deliberately doesn't, so no font bloat. Tailscale, neovim, and gh are the
larger single additions if you want to trim.

### Design 2 — embed the full **target closure** for true offline install (NOT recommended)

To install with *no network at all*, you'd have to bake the entire built closure of
`nixosConfigurations.notebook.config.system.build.toplevel` into the ISO store (e.g. via
`isoImage.storeContents` / adding the toplevel to the closure). That closure includes the full
niri desktop, firefox, libreoffice, vesktop, **nixvim** (large Python-LSP closure), the whole
home-manager environment, etc.

- Realistic uncompressed target closure: **~8–15 GB**; compressed into the ISO: **~4–7 GB**.
- This is exactly the pathology `AGENTS.md` 427 warns about for `disko-install` ("packages like
  nixvim have large closures that exceed typical ISO RAM/space"). A live ISO copies its
  squashfs into RAM-backed overlays, so a 5+ GB ISO also demands a lot of RAM.
- **Verdict:** not worth it. `nixos-install` fetching from a binary cache is the normal path
  and keeps the ISO small. Only pursue Design 2 if you genuinely need to install with no
  internet on the target — and even then, a local substituter or `nix copy` to the target is
  usually better than a giant ISO.

**Bottom line:** plan for a **~1.4 GB ISO** (Design 1). Baseline minimal installer is ~1.1 GB;
this loaded, toolbelt-heavy variant lands a few hundred MB above that.

---

## 9. Build time & resource expectations

- **First build is dominated by squashfs compression.** Fetching the store paths is fast if
  your cache is warm; assembling and zstd-compressing a ~2–3 GB store tree into squashfs is the
  slow, CPU-bound step. On a modern multi-core laptop expect **~3–10 minutes** for a full build
  at the default high compression, more on the first run when paths must be downloaded/built.

- **`isoImage.squashfsCompression` is the main tuning knob.**
  - Default (`"xz"` historically, or high-level zstd) → smallest ISO, slowest build.
  - While iterating on the module/aliases/script, set something like
    `"zstd -Xcompression-level 3"` (or even `-Xcompression-level 1`) to make rebuilds
    **markedly faster** at the cost of a somewhat larger ISO. Because you rebuild the ISO many
    times while getting the install script right, this trade-off is worth it during
    development.
  - For the "release" ISO you actually flash to USB, bump it back to a high zstd level (e.g.
    `6`) or `xz` for the smallest artifact.

- **Rebuild locality.** Changing only the install script / aliases / package list invalidates
  the squashfs and re-runs compression, but the underlying store paths are cached — so the cost
  is essentially "recompress", not "rebuild the world".

- **RAM/disk.** Building needs enough `/tmp` + store space for the uncompressed tree plus the
  squashfs (a few GB free). Booting the *resulting* ISO in a VM needs ≥2–4 GB guest RAM
  (the live system runs from a RAM overlay); give the QEMU test VM 4 GB.

---

## 10. In-repo vs separate-repo

**Recommendation: keep it in this repo.**

- The ISO's entire value is installing/repairing *this* config — co-location guarantees it
  always matches the current modules and the same `flake.lock`.
- `inputs.self` embedding (offline-friendly install, `/etc/nixos-config`, registry alias) is
  trivial in-repo and awkward cross-repo (you'd embed a pinned external input that can drift).
- It fits the dendritic convention perfectly: it's just another file under `modules/hosts/`.
- No duplicated flake-parts scaffolding and no second lockfile to babysit.

A **separate repo** only pays off if you want to publish a *config-agnostic* generic NixOS
rescue ISO, or run CI that cuts ISO release artifacts without touching this repo's history.
Neither applies to a personal installer/rescue tool.

---

## 11. Ordered implementation + QEMU testing

*(For when you decide to proceed — not done yet.)*

1. Create `modules/hosts/iso.nix` per §4 (`installer-iso` module + `nixosConfigurations.iso`
   + `perSystem.packages.iso`).
2. **`git add modules/hosts/iso.nix`** — mandatory; untracked files are invisible to flake
   eval (`AGENTS.md` 147).
3. Add the `nixos-config-install` `writeShellApplication` (§7), inline in `iso.nix` or in a
   `modules/hosts/_iso-install.nix` helper imported from `iso.nix`.
4. **Eval check:** `nix flake check --no-build --no-eval-cache`.
5. **Build:** `nix build '.#nixosConfigurations.iso.config.system.build.isoImage'`
   → `result/iso/nixos-config-installer.iso`. Use a low zstd level (§9) while iterating.
6. **Boot-test in QEMU (UEFI, OVMF).** Do **not** use `qemu.nix` (that's for the installed
   host); use ad-hoc tooling:
   ```bash
   nix shell nixpkgs#qemu nixpkgs#OVMF -c \
     qemu-system-x86_64 -enable-kvm -m 4096 \
       -drive if=pflash,format=raw,readonly=on,file=$(nix eval --raw nixpkgs#OVMF.fd)/FV/OVMF.fd \
       -cdrom result/iso/*.iso
   ```
   Verify: boots to the auto-login shell; aliases resolve; `disko`, `nixos-install`, `age`,
   `sops`, `git` are on `PATH`; `/etc/nixos-config` holds the flake.
7. **Full install dry-run in QEMU.** Add a blank virtual disk plus a small second "USB" disk
   carrying a dummy `keys.txt`, boot the ISO, run `install-vm`, and confirm the
   disko → age-copy → `nixos-install` flow completes against the `vm` host
   (`diskoConfigDevice = /dev/disk/by-id/virtio-ROOT`, `vm.nix:27` — the natural test target
   since its disk is a virtio path). Then boot the resulting disk to confirm login (i.e. that
   the age key decrypted the password) works.
8. (Optional) Document the flash step (`dd if=… of=/dev/sdX bs=4M status=progress`) in README.

---

## 12. Risks & gotchas

- **Do NOT import `disko` or `persistence` into the ISO.** `disko.nix` defines the *target's*
  on-disk layout, requires `diskoConfigDevice`/`diskoSwapSize`, and would collide with the
  ISO's read-only squashfs filesystem. `persistence.nix` is impermanence for an installed
  host and is meaningless on a live ISO. The ISO needs only the disko **CLI tool**, not the
  module. (This is also why you must build with a plain `nixosSystem`, not `mkNixos`, which
  force-injects the disko module.)

- **`git add` before every build.** Nix flake evaluation reads the git tree; a freshly created
  `modules/hosts/iso.nix` is invisible until added (`AGENTS.md` 147).

- **`flake.nix` is generated.** Option A adds no inputs, so no edit and no `write-flake` run.
  If you ever go Option B (nixos-generators), you must add `flake-file.inputs` and run
  `nix run .#write-flake`.

- **Offline install nuance.** Embedding `inputs.self` gives you the flake *source* offline, not
  the built *closure*. `nixos-install` still pulls the target's store paths from a binary cache
  over the network. Truly offline install means baking the multi-GB target closure into the ISO
  (Design 2, §8) — generally not worth it, and it risks the RAM/space problem `AGENTS.md` 427
  calls out.

- **USB age-key bootstrap is load-bearing.** If the age key isn't copied to
  `/mnt/persist/home/sean/.keys/age.txt` before `nixos-install`, activation fails decrypting the
  login password (`neededForUsers`). The install script must hard-abort when it's missing rather
  than proceed to a broken install.

- **LUKS passphrase is interactive and entered twice in the lifecycle** — once at `disko`
  format time, and again at every boot's initrd prompt (no keyfile; `AGENTS.md` 469). Expected,
  not a bug.

- **ISO name collision / `mkForce`.** The installer profile sets a default `isoImage.isoName`;
  override with `lib.mkForce` if you want a custom filename.

- **RAM at boot.** The live system runs from a RAM overlay; give VM tests ≥4 GB, and be aware a
  very large ISO (Design 2) needs correspondingly more RAM to boot.

---

## 13. Concrete nixpkgs reference

Actionable names for the eventual implementation:

- **Base profile module:** `(modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")`
  - It already imports `installer/cd-dvd/iso-image.nix` and a base/no-desktop profile, sets up
    the `nixos` auto-login user, and enables `nix`/ssh.
  - Graphical alternative (not recommended here, much larger):
    `installer/cd-dvd/installation-cd-graphical-calamares.nix`.
- **Build output:** `config.system.build.isoImage` → produces `result/iso/<isoName>`.
- **Options** (from `iso-image.nix`; present only once the profile is imported, hence not in
  search.nixos.org):
  - `isoImage.isoName` — output filename.
  - `isoImage.squashfsCompression` — e.g. `"zstd -Xcompression-level 6"` or `"xz"`; the main
    build-time/size knob.
  - `isoImage.makeEfiBootable` — EFI boot entry.
  - `isoImage.makeUsbBootable` — hybrid image that works `dd`-ed to a USB stick.
  - `isoImage.storeContents` — extra store paths to bake in (this is the lever for Design 2
    offline installs; leave unused for the recommended Design 1).
- **Toolbelt packages verified present:** `nixos-install-tools` (26.05pre-git),
  `disko` (v1.13.0, prefer `inputs.disko.packages.${system}.disko`), plus the standard
  `cryptsetup`/`btrfs-progs`/`parted`/`age`/`sops`/`neovim`/etc.
- **Alternative generator (Option B):** `nixos-generators` v1.8.0, `format = "install-iso"`.

---

*End of research document. No changes have been made to the flake; implementing §4/§7 is a
separate, explicit step.*
