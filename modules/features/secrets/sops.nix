{ inputs, ... }:
{
  flake-file.inputs = {
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.modules.homeManager.sops =
    { config, ... }:
    {
      imports = [ inputs.sops-nix.homeManagerModules.sops ];

      home.sessionVariables.SOPS_AGE_KEY_FILE = "${config.home.homeDirectory}/.keys/age.txt";

      persist.files = [
        {
          file = ".keys/age.txt";
          configureParent = true;
        }
      ];

      sops = {
        defaultSopsFile = ./secrets.yaml;
        age.keyFile = "${config.home.homeDirectory}/.keys/age.txt";
      };

      sops.secrets."sean_ssh_id_ed25519" = {
        path = "${config.home.homeDirectory}/.keys/generated_keys/id_ed25519";
        mode = "0600";
      };

    };

  flake.modules.nixos.sops =
    { pkgs, ... }:
    {
      imports = [ inputs.sops-nix.nixosModules.sops ];

      sops = {
        defaultSopsFile = ./secrets.yaml;
        age.keyFile = "/persist/home/sean/.keys/age.txt";
      };

      environment.systemPackages = [ pkgs.sops ];
    };
}
