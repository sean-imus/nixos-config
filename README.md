# nixos-config

> One repo. Two machines. Zero manual steps after install.

My personal NixOS configuration for a notebook and a VM — every OS setting, package, disk layout, secret, and dotfile declared as code and version-controlled.

---

## What is this? (for non-Nix people)

Most operating systems work like a backpack: you keep throwing things in, and over months or years it gets heavier, messier, and you're never quite sure what's in there. If something breaks, good luck figuring out what changed. Migrating to a new PC? Reinstalling from scratch? Running two machines in sync? A nightmare on conventional systems. Here's how I handle it instead.

**Everything is code.** Disk layout, installed programs, desktop environment, users, dotfiles, Wi-Fi passwords, SSH keys — all of it lives in this repository as Nix expressions. The system is what the repo says it is. Nothing more.

**Nothing sticks unless you opt in.** The system root is wiped on every reboot. No orphaned config files, no dependency rot, no accumulated junk. Only what you explicitly declare survives. Browser cache, stray downloads, forgotten screenshots — gone. A clean slate every boot, with your actual important stuff intact. This is the closest you'll ever get to a single source of truth for your entire operating system.

**You can't lose your system.** Every rebuild produces a new immutable generation sitting next to all previous ones in the boot menu. Broke something? Boot the last working entry. Experiment backfired? Same. Drive died? Restore the age key, run two commands, get the exact same system back.

---

## What's in here

| Layer | Details |
|---|---|
| Disk | LUKS encryption · Btrfs subvolumes · tmpfs root (ephemeral `/`) · declarative partitioning via disko |
| Boot | systemd-boot · per-generation entries |
| Network | NetworkManager · systemd-resolved with DNS-over-TLS · Tailscale · declarative Wi-Fi profiles |
| Desktop | Niri compositor · Waybar · Alacritty · qutebrowser · Vesktop · fuzzel |
| Shell | zsh · starship · fzf history search · bat |
| Editor | Neovim via nixvim |
| Services | PipeWire audio · Bluetooth · QEMU/libvirt · printing · RDP |
| Secrets | sops-nix: SSH keys · login password · Wi-Fi PSKs — all encrypted at rest, decrypted at boot |
| Persistence | opt-in only: age key · audio state · `~/persist` |

---

## Highlights

**Declarative Wi-Fi.** Passwords live in `secrets.yaml` as age-encrypted ciphertext — never plaintext, never in the Nix store. At boot, sops-nix decrypts them to `/run/secrets/` (tmpfs) and `nm-file-secret-agent` hands them to NetworkManager at connect time. Adding a new network is one line of Nix and one line in the secrets file.

**Ephemeral root.** `/` is a tmpfs. Every boot is a clean slate. State you care about is explicitly listed and symlinked from `/persist`. Everything else disappears.

**Instant rollback.** `nixos-rebuild switch` creates a new generation. If it breaks anything, the previous generation is one reboot away.

**One age key, everything else follows.** The age key is the only secret that can't be stored in the repo. Everything else — SSH identities, passwords, Wi-Fi PSKs — is encrypted against it and provisions itself automatically on install.

---

## How it works

### The Nix language

All config is written in Nix: a purely functional, lazily evaluated language designed for describing environments. Think JSON with functions and imports. NixOS uses it to describe an entire OS. Home Manager uses it to describe a user environment. Both live here.

### Flakes

A `flake.nix` at the root pins every dependency (nixpkgs, home-manager, sops-nix, disko, …) to exact commits via `flake.lock`. Every machine builds from the same locked inputs. No surprises from upstream.

### One repo, two machines

Each host is a file that imports whichever modules it needs. The notebook gets the full desktop stack. The VM gets the same desktop with minor tweaks (Alt as mod, virtio disk). Hardware differences (disk ID, kernel modules, swap size, display layout) are per-host. Everything else is shared.

### Secrets: encrypted in git, decrypted at boot

`modules/features/secrets/secrets.yaml` is committed as age-encrypted ciphertext. sops-nix decrypts it during activation and places each secret at the right path with the right permissions. The age key lives on disk at `~/.config/sops/age/keys.txt` (preserved across reboots, backed up to USB). It's the one secret that must exist before anything else can be decrypted.

### Ephemeral root via tmpfs

`/` is mounted as tmpfs and wiped on every reboot. The `preservation` module maintains an explicit list of directories and files to bind-mount from `/persist`. Anything not on that list is gone after a reboot — intentionally.

---

## Installation

**This wipes the entire target disk.**

```bash
# 0. Boot a NixOS ISO

# 1. Partition and format
nix-shell -p disko
sudo disko --mode disko --flake github:sean-imus/nixos-config#[notebook|vm]

# 2. Copy the age key from USB (needed to decrypt secrets during install)
lsblk   # find your USB device
mkdir -p /mnt/usb && mount /dev/sdX1 /mnt/usb
mkdir -p /mnt/persist/home/sean/.config/sops/age
cp /mnt/usb/keys.txt /mnt/persist/home/sean/.config/sops/age/keys.txt
chmod 600 /mnt/persist/home/sean/.config/sops/age/keys.txt
umount /mnt/usb

# 3. Install
sudo nixos-install --no-channel-copy --no-root-password --flake github:sean-imus/nixos-config#[notebook|vm]
```
