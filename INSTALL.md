# Dendritic NixOS Configuration

A machine-independent NixOS configuration using the Dendritic pattern.

## Directory Structure

```
nixos-config/
├── flake.nix                      # Entry point
├── hardware-configuration.nix    # Per-machine hardware (generated)
├── hosts/
│   └── default/
│       └── default.nix            # Host config (hostname, user)
├── nixos/                         # System modules (one feature per file)
│   ├── boot.nix                   # Bootloader config
│   ├── networking.nix             # NetworkManager
│   ├── locale.nix                 # Timezone, keyboard
│   ├── desktop.nix                # GNOME/GDM
│   ├── sound.nix                  # PipeWire
│   ├── touchpad.nix               # Libinput
│   ├── users.nix                  # User groups
│   ├── packages.nix               # System packages
│   └── nix.nix                   # Nix settings
└── home/                          # Home-manager modules
    ├── bash.nix                   # Shell aliases
    ├── alacritty.nix               # Terminal config
    ├── git.nix                    # Git config
    ├── ssh.nix                    # SSH config
    ├── chromium.nix                # Browser + extensions
    ├── neovim.nix                 # Editor config
    └── packages.nix               # User packages
```

## Dendritic Pattern

- **Every file is a module**: Each `.nix` file in `nixos/` and `home/` implements ONE feature
- **File path = feature name**: The path represents the feature, not a file type
- **Composable**: Add new features by creating new files

## Installation on New Machine

### Step 1: Boot NixOS Installer

1. Download NixOS ISO from https://nixos.org/download.html
2. Boot from USB or virtual media

### Step 2: Partition and Format

```bash
# Create partitions (example for UEFI)
sudo parted /dev/sda -- mklabel gpt
sudo parted /dev/sda -- mkpart ESP 512MiB -1GB
sudo parted /dev/sda -- mkpart swap 1GB -2GB  
sudo parted /dev/sda -- mkpart root 2GB -1GB

# Format
sudo mkfs.fat -F32 /dev/sda1
sudo mkswap /dev/sda2
sudo mkfs.ext4 /dev/sda3
```

### Step 3: Mount and Generate Hardware Config

```bash
# Mount root
sudo mount /dev/sda3 /mnt
sudo mkdir /mnt/boot
sudo mount /dev/sda1 /mnt/boot
sudo swapon /dev/sda2

# Generate hardware config (this creates hardware-configuration.nix)
sudo nixos-generate-config --root /mnt

# Copy to this repo location (edit path as needed)
cp /mnt/etc/nixos/hardware-configuration.nix ~/nixos-config/
```

### Step 4: Clone Your Config

```bash
# Clone your flake repo
git clone https://github.com/YOUR_USERNAME/nixos-config.git /etc/nixos

cd /etc/nixos

# IMPORTANT: Update hardware-configuration.nix with the file from Step 3
# It should contain the correct fileSystems."/" device paths

# Optional: Edit hostname in hosts/default/default.nix
nvim hosts/default/default.nix
```

### Step 5: Install

```bash
# First test (dry run)
sudo nixos-rebuild build --flake .#nixos

# Install (this is the final step!)
sudo nixos-rebuild switch --flake .#nixos
```

### Step 6: Reboot

```bash
sudo reboot
```

## Adding a New Machine

1. Create host directory:
   ```bash
   mkdir -p hosts/<machine-name>
   ```

2. Copy host config:
   ```bash
   cp hosts/default/default.nix hosts/<machine-name>/
   ```

3. Edit hostname in new file

4. Add to flake.nix if using a custom name (default is "nixos")

5. Build with:
   ```bash
   nixos-rebuild switch --flake .#<machine-name>
   ```

## Common Commands

```bash
# Build system (without installing)
nixos-rebuild build --flake .

# Apply changes
nixos-rebuild switch --flake .

# Update packages
sudo nix flake update

# Check configuration
nix eval .#nixosConfigurations.nixos.config.system.build.toplevel

# Roll back
sudo nixos-rebuild switch --flake .#nixos --rollback
```

## Configuration Files Explained

### flake.nix
- Entry point that builds NixOS configuration
- Defines inputs (nixpkgs, home-manager)
- Imports all modules

### nixos/*.nix (System Modules)
Each file configures one system feature:
- **boot.nix**: systemd-boot, EFI
- **networking.nix**: NetworkManager
- **locale.nix**: Timezone (Europe/Berlin), keyboard (de)
- **desktop.nix**: GDM + GNOME
- **sound.nix**: PipeWire
- **packages.nix**: System packages (neovim, wget, bat, etc.)
- **nix.nix**: Experimental features, garbage collection

### home/*.nix (Home Manager Modules)
Each file configures one user feature:
- **bash.nix**: Shell aliases (lg, lj)
- **alacritty.nix**: Terminal font, scrollback
- **git.nix**: User name, email
- **ssh.nix**: GitHub SSH config
- **chromium.nix**: Browser + uBlock Origin
- **packages.nix**: User packages (lazygit, fastfetch, etc.)

### hosts/default/default.nix
- Host-specific settings
- hostname: "nixos" (change for new machines)
- user: "sean"

## For More Info

- NixOS Flakes: https://wiki.nixos.org/wiki/Flakes
- Dendritic Pattern: https://github.com/mightyiam/dendritic
- Home Manager: https://nix-community.github.io/home-manager/