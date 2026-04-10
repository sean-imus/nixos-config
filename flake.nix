# =============================================================================
# DENDRITIC NIXOS CONFIGURATION
# =============================================================================
#
# DIRECTORY STRUCTURE:
#   flake.nix           - Entry point (imports all modules)
#   hosts/default.nix   - Host configuration
#   nixos/          - NixOS system modules (one feature per file)
#   home/           - Home-manager user modules (one feature per file)
#
# USAGE:
#   nixos-rebuild switch --flake .#nixos
# =============================================================================

{
  description = "Dendritic NixOS configuration";

  # =============================================================================
  # INPUTS
  # =============================================================================
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # =============================================================================
  # OUTPUTS
  # =============================================================================
  outputs =
    inputs@{ nixpkgs, home-manager, ... }:

    {
      # Create NixOS configuration for "nixos" hostname
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;

        modules = [
          # ========================================================================
          # HOME-MANAGER
          # ========================================================================
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.users.sean = {
              imports = [
                ./home/bash.nix
                ./home/alacritty.nix
                ./home/git.nix
                ./home/ssh.nix
                ./home/chromium.nix
                ./home/neovim.nix
                ./home/packages.nix
              ];
              home.username = "sean";
              home.homeDirectory = "/home/sean";
              home.stateVersion = "25.11";
            };
          }

          # ========================================================================
          # NIXOS SYSTEM MODULES
          # ========================================================================
          ./hardware-configuration.nix
          ./nixos/boot.nix
          ./nixos/networking.nix
          ./nixos/locale.nix
          ./nixos/desktop.nix
          ./nixos/sound.nix
          ./nixos/touchpad.nix
          ./nixos/users.nix
          ./nixos/packages.nix
          ./nixos/nix.nix

          # Host specific config
          ./hosts/default/default.nix
        ];
      };
    };
}
