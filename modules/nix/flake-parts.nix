{ inputs, ... }:
{
  # Framework entrypoint. `flakeModules.modules` provides the flake.modules.*
  # namespace that every feature registers into; `flakeModules.dendritic` wires
  # flake-file so inputs declared as `flake-file.inputs` land in flake.nix.
  imports = [
    inputs.flake-parts.flakeModules.modules
    inputs.flake-file.flakeModules.dendritic
  ];

  flake-file.inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  systems = [ "x86_64-linux" ];

  # Turns a registered host aspect (flake.modules.nixos.<name>) into a real
  # nixosConfiguration, always injecting home-manager + disko. Host files call
  # this as `flake.nixosConfigurations = mkNixos "x86_64-linux" "notebook"`.
  flake.lib.mkNixos = system: name: {
    ${name} = inputs.nixpkgs.lib.nixosSystem {
      modules = [
        inputs.self.modules.nixos.${name}
        inputs.home-manager.nixosModules.home-manager
        inputs.disko.nixosModules.disko
        { nixpkgs.hostPlatform = system; }
      ];
    };
  };

}
