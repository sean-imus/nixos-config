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

      home.sessionVariables.SOPS_AGE_KEY_FILE = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

      sops = {
        defaultSopsFile = ./secrets.yaml;
        age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
      };

      # TEMPORARY: sops HM secrets disabled during recovery – re-enable once sops-nix HM service is stable
      # sops.secrets."sean_ssh_id_ed25519" = {
      #   path = "${config.home.homeDirectory}/.ssh/id_ed25519";
      #   mode = "0600";
      # };

    };

  flake.modules.nixos.sops =
    { pkgs, ... }:
    {
      imports = [ inputs.sops-nix.nixosModules.sops ];

      sops = {
        defaultSopsFile = ./secrets.yaml;
        age.keyFile = "/persist/home/sean/.config/sops/age/keys.txt";
      };

      environment.systemPackages = [ pkgs.sops ];
    };
}
