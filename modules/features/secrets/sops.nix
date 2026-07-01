{ inputs, ... }:
let
  # Single source of truth for the age-key location relative to $HOME.
  # Referenced by every consumer below (session var, persist entry, HM keyFile,
  # and — via the derived /persist path — the NixOS keyFile) so a future rename
  # touches exactly one line. Must stay byte-identical across all consumers,
  # otherwise the HM and NixOS keyFile values would diverge and trigger a live
  # key migration.
  ageKeyRelPath = ".keys/age.txt";
in
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

      sops.secrets."sean_ssh_id_ed25519" = {
        path = "${config.home.homeDirectory}/.keys/generated_keys/id_ed25519";
        mode = "0600";
      };

    };

  flake.modules.nixos.sops =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      # Derive the username instead of hardcoding "sean", honoring the
      # "features must be user-independent" rule. The username comes from the
      # set of home-manager users — we only force the attribute *names*, which
      # is cheap and free of the sops eval cycle (nothing in a user's HM config
      # depends on this NixOS keyFile), so there is no bootstrap recursion.
      hmUsers = builtins.attrNames config.home-manager.users;
      primaryUser = lib.head hmUsers;
    in
    {
      imports = [ inputs.sops-nix.nixosModules.sops ];

      sops = {
        defaultSopsFile = ./secrets.yaml;
        # WHY the raw /persist path (not ~/${ageKeyRelPath}): this key is read
        # at the `neededForUsers` stage, which runs *before* the per-user home
        # bind-mount from /persist is in place — so ~ would not yet resolve to
        # the persisted key. It must reference the physical /persist location
        # directly, and must stay byte-identical to the HM age.keyFile above so
        # no live key migration is triggered.
        age.keyFile = "/persist/home/${primaryUser}/${ageKeyRelPath}";
      };

      environment.systemPackages = [ pkgs.sops ];
    };
}
