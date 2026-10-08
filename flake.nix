{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    import-tree.url = "github:vic/import-tree";

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

    yazi-everforest = {
      url = "github:jcarter/everforest-yazi";
      flake = false;
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      { config, lib, ... }:
      {
        imports = [
          inputs.flake-parts.flakeModules.modules
          (inputs.import-tree ./modules)
        ];

        systems = [ "x86_64-linux" ];

        perSystem =
          { pkgs, ... }:
          {
            formatter = pkgs.nixfmt-tree;
          };

        flake.modules.nixos = lib.mapAttrs (_: module: {
          home-manager.sharedModules = [ module ];
        }) config.flake.modules.homeManager;
      }
    );
}
