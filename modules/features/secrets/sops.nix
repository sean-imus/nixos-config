{ inputs, ... }:
let
  # Single source of truth for the age key location. Every consumer below
  # (session var, persist, HM keyFile, NixOS keyFile) derives from this, so a
  # rename is one line. The age key is the ONE secret that must exist on disk
  # before anything else can be decrypted.
  ageKeyRelPath = ".keys/age.txt";
in
{
  flake-file.inputs = {
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # sops is a core, always-on capability, so its HM half lives in the `core`
  # bucket rather than as a separately-imported module: any user importing core
  # gets secret management, and core features (git token, ssh id) can reference
  # sops.secrets.* directly because they merge into this same module.
  flake.modules.homeManager.core =
    { config, ... }:
    {
      imports = [ inputs.sops-nix.homeManagerModules.sops ];

      home.sessionVariables.SOPS_AGE_KEY_FILE = "${config.home.homeDirectory}/${ageKeyRelPath}";

      persist.files = [
        {
          file = ageKeyRelPath;
          configureParent = true;
        }
      ];

      sops = {
        defaultSopsFile = ./secrets.yaml;
        age.keyFile = "${config.home.homeDirectory}/${ageKeyRelPath}";
      };

      # Regenerated from secrets.yaml every activation — NOT persisted. Consumers
      # reference this path (config.sops.secrets.*.path), never a literal.
      sops.secrets."sean_ssh_id_ed25519" = {
        path = "${config.home.homeDirectory}/.keys/generated_keys/id_ed25519";
        mode = "0600";
      };
    };

  # NixOS half stays a named aspect: it is imported explicitly by the modules
  # that decrypt system secrets (the user account for the login password, plus
  # wifi/tailscale for their keys), not pulled in by a bucket.
  flake.modules.nixos.sops =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      # Second sops surface, same key: the NixOS layer decrypts neededForUsers
      # secrets (login password) at a stage that runs BEFORE the home bind-mount
      # exists, so it must read the key from the raw /persist path. Deriving the
      # user from the HM attr names (only the *names* are forced — cheap, no sops
      # eval cycle) keeps this from hardcoding a username.
      primaryUser = lib.head (builtins.attrNames config.home-manager.users);
    in
    {
      imports = [ inputs.sops-nix.nixosModules.sops ];

      sops = {
        defaultSopsFile = ./secrets.yaml;
        age.keyFile = "/persist/home/${primaryUser}/${ageKeyRelPath}";
      };

      environment.systemPackages = [ pkgs.sops ];
    };
}
