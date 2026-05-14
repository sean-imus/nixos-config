# nixos-config

My personal NixOS configuration for a single laptop (planning to add a server config aswell, ground framework is already set for that).

## What is this? (for non-Nix people)

Most operating systems work like a backpack: you keep throwing things in, and over months or years it gets heavier, messier, and you're never quite sure what's in there. If something breaks, good luck figuring out what changed.

This repo takes the opposite approach. My entire operating system — disk layout, installed programs, desktop environment, settings, everything — is defined as code in a single Git repository.

**Nothing sticks unless you opt in.** The system root is wiped on every reboot. That means no orphaned config files, no dependency rot, no accumulated junk. Only what you explicitly declare gets preserved: SSH keys, Wi-Fi passwords, audio settings, firmware state, and anything you put in `~/persist`. Browser profiles, downloads, desktop clutter — all gone. A factory reset every time you turn it on, but your actual important stuff is still there.

**Total peace of mind.** Every system change creates a new immutable "generation" that sits next to all previous ones in your boot menu. Upgrade broken something? Reboot and pick the last working one. Experiment backfired? Same thing. You can't hose your system — there's always a working entry to fall back to. And if your drive dies or you get a new laptop, two commands rebuild the *exact* same system from scratch. No manual reinstallation, no "I forgot what I had installed," no drift from what worked before.

**What's in this config:**

| Layer | What it does |
|-------|-------------|
| Disk | GPT + LUKS encryption + Btrfs + tmpfs root (ephemeral `/`) |
| System | bootloader, networking, firewall, kernel, drivers |
| Desktop | Niri (tiling Wayland compositor), Waybar, Alacritty, Neovim, Firefox, Vesktop |
| User | shell, git identity, SSH, Neovim plugins, Firefox bookmarks |
| Services | printing, QEMU VMs, remote desktop via xrdp, PipeWire audio, Bluetooth |
| Persistence | opt-in only: SSH keys, Wi-Fi passwords, audio config, firmware metadata, logs, and `~/persist` |

## Install from a live USB

**This wipes the entire target disk.** You'll be prompted for a LUKS encryption password during step 1, and again at every boot.

```bash
# 1. Format Drive
nix-shell -p disko && sudo disko --mode disko --flake github:sean-imus/nixos-config#[host, notebook, server, etc.]

# 2. Install System
sudo nixos-install --no-channel-copy --no-root-password --flake github:sean-imus/nixos-config#[host, notebook, server, etc.]
```
