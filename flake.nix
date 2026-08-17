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

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim.url = "github:nix-community/nixvim";
  };

  outputs =
    { nixpkgs, ... }@inputs:
    let
      mkHost =
        host:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            inputs.disko.nixosModules.disko
            inputs.home-manager.nixosModules.home-manager
            inputs.sops-nix.nixosModules.sops
            host
          ];
        };
    in
    {
      nixosConfigurations.work-notebook = mkHost ./modules/hosts/work-notebook.nix;
    };
}
