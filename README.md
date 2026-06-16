# nixos-config
## 3 min read, probably a lot more to fully understand.

My personal NixOS configuration for my notebook and a VM. All managed by a single repo.

## What is this? (for non-Nix people)

Most operating systems work like a backpack: you keep throwing things in, and over months or years it gets heavier, messier, and you're never quite sure what's in there. If something breaks, good luck figuring out what changed. Trying to migrate to a different PC? Wanting to use multiple PCs concurrently? Need to reinstall your system for whatever reason? Hell on Earth on other OSes compared to how I manage it.

My entire operating system: disk layout, installed programs, desktop environment, users and all their configurations, settings, everything is **defined as code in a single Git repository**. This makes it transferable, immutable, and most importantly, reproducible.

**Nothing else sticks unless you opt in.** The system root is wiped on every reboot. That means no orphaned config files, no dependency rot, no accumulated junk. Only what you explicitly declare gets preserved: things like SSH keys, Wi-Fi passwords, audio settings, and anything you put in `~/persist`. Browser cache, downloads, those screenshots you forgot, all gone. A factory reset every time you turn it on, but your actual important stuff is still there. This is the closest one will ever get to having one central location depicting the entire truth of their operating system. What is not declared in this repo **will not** exist after a reboot. This is powerful and lets you experiment however much you like. Break your SSH config? Reboot. Delete your entire home directory? Reboot. It will be like nothing ever happened. 

**Total peace of mind.** Every system rebuild creates a new immutable "generation" that sits next to all previous ones in your boot menu. You edited your NixOS config and something broke? Reboot and pick the last working generation. Experiment backfired? Same thing. You can't lose your system. There's always a working entry to fall back to. And if your drive dies or you get a new laptop, two commands rebuild the *exact* same system from scratch, just like rebooting a totally working system. No manual disk setup, no "I forgot what I had installed," no drift from what worked before.

**What's in this config:**

| Layer | What it does |
|-------|-------------|
| Disk | LUKS encryption, Btrfs, tmpfs root (ephemeral `/`) |
| System | systemd-boot, networkmanager |
| Desktop | Niri, Waybar, Alacritty, Neovim, qutebrowser, Vesktop |
| User | zsh, Neovim plugins, Firefox bookmarks + extensions, etc. |
| Services | printing, QEMU VMs, remote desktop via xrdp, PipeWire audio, Bluetooth, etc. |
| Persistence | opt-in only: SSH keys, Wi-Fi passwords, audio config, and `~/persist` |

## How?

Now that we have gotten the top-level stuff out of the way, let's talk about how all that nice-sounding stuff actually comes to life. Warning: it will be technical. Please ask your local Nix expert, the web, or even an AI about the terms I will be using here.

### **The Nix Language.**
All the code you see in this repo was written in Nix. It's most commonly described as JSON with functions, but that doesn't do it justice. Its goal is to configure environments, nothing more, nothing less.

**NixOS** uses Nix to configure an entire operating system. But Nix itself is much broader: it compiles packages, builds dev environments (like Python venvs), or anything else in that nature. The ecosystem has grown enough that you can now declaratively set up an Apple Mac with it too.

**Nix flakes** take this further. A `flake.nix` file declares your dev environment: what shell to use, its config, what packages to install, and more. Want to work on a project on Arch that needs Python and some modules? Create a `flake.nix`, type `nix develop`, and you're dropped into a shell with everything ready. Your friend on Debian gets the exact same environment. The first run creates a `flake.lock` file that pins every dependency version, so nothing changes unless you explicitly run `nix flake update`.

### One repo, multiple machines

Each host is just a file that picks which modules to import. The notebook gets the full desktop stack. The VM gets the same desktop with a few tweaks (Alt as mod key, virtio disk). Hardware differences are handled the same way — each host sets its own `diskoConfigDevice` to point at the right drive, its own kernel modules, its own swap size. Everything else is shared.

### Secrets in git, decrypted at boot

My SSH private key, API keys, and other sensitive data live in an encrypted `secrets.yaml` file that is committed to git as ciphertext. An age key stored on disk (and preserved across reboots) decrypts everything at activation time. sops-nix then places each secret at the correct path with the correct permissions automatically. Rotate the key? Generate a new one, re-encrypt, commit, rebuild. Done. Reinstall NixOS? Just restore the age key from backup and everything provisions itself.

This is the one thing that isn't fully declarative: the age key has to exist on disk before sops can decrypt anything. But managing one key beats remembering where to put eight SSH keys and a dozen API tokens across a fresh install.

### Disks as code

No `fdisk`, no `cryptsetup`, no `mkfs.btrfs` during system installation. The entire disk layout (ESP partition, LUKS encryption, GPT, Btrfs subvolumes, encrypted swap) is defined as Nix code. A single parameter (`diskoConfigDevice`) changes between hosts to point at the right physical drive. The `disko` command partitions, formats, and mounts.

## Installation

**This wipes the entire target disk.**

```
# 0. Boot a NixOS ISO

# 1. Format and partition the disk
nix-shell -p disko
sudo disko --mode disko --flake github:sean-imus/nixos-config#[notebook/vm]

# 2. Copy the sops age key from USB
#    (required to decrypt secrets — including the login password — during install)
lsblk   # find your USB device
mkdir -p /mnt/usb && mount /dev/sdX1 /mnt/usb
mkdir -p /mnt/persist/home/sean/.config/sops/age
cp /mnt/usb/keys.txt /mnt/persist/home/sean/.config/sops/age/keys.txt
chmod 600 /mnt/persist/home/sean/.config/sops/age/keys.txt
umount /mnt/usb

# 3. Install System (builds directly on the target disk, not the ISO)
sudo nixos-install --no-channel-copy --no-root-password --flake github:sean-imus/nixos-config#[notebook/vm]
```
