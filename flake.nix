{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim.url = "github:nix-community/nixvim";

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    {
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-tree;

      apps.x86_64-linux.install = {
        type = "app";
        program = nixpkgs.lib.getExe (
          nixpkgs.legacyPackages.x86_64-linux.writeShellApplication {
            name = "install";
            runtimeInputs = [
              inputs.disko.packages.x86_64-linux.disko
              nixpkgs.legacyPackages.x86_64-linux.git
            ];
            text = ''
              [ "$EUID" -eq 0 ] || exec sudo "$0" "$@"
              export NIX_CONFIG="experimental-features = nix-command flakes"
              usb=''${1:?usage: install <mounted usb directory>}

              disko --mode destroy,format,mount --flake ${self}#notebook

              mkdir -p /mnt/home/sean/.secrets
              cp "$usb/Privat/password.txt" /mnt/home/sean/.secrets/
              chmod 600 /mnt/home/sean/.secrets/password.txt
              git clone https://github.com/sean-imus/nixos-config /mnt/home/sean/nixos-config
              chown 1000:1000 /mnt/home/sean
              chown -R 1000:1000 /mnt/home/sean/.secrets /mnt/home/sean/nixos-config

              nixos-install --no-channel-copy --no-root-password --flake ${self}#notebook
              echo "Done. Unplug the USB and reboot."
            '';
          }
        );
      };

      nixosConfigurations.notebook = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          inputs.disko.nixosModules.disko
          inputs.home-manager.nixosModules.home-manager
          ./modules/notebook.nix
        ];
      };
    };
}
