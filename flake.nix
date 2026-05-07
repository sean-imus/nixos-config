{
  description = "Entry Flake";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Declarative Firefox Extensions
    nix-firefox-addons = {
      url = "github:OsiPog/nix-firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Declarative Vimium Settings
    vimium-options = {
      url = "github:uimataso/vimium-nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      nix-firefox-addons,
      vimium-options,
      ...
    }:
    {
      nixosConfigurations = {
        "notebook" = nixpkgs.lib.nixosSystem {
          modules = [
            ./hosts/notebook.nix
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.sean = import ./users/sean.nix;
                sharedModules = [ vimium-options.homeManagerModules.default ];
              };
            }
            {
              nixpkgs.overlays = [
                nix-firefox-addons.overlays.default
              ];
            }
          ];
        };
      };
    };
}
