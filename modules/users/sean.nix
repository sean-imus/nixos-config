{ inputs, ... }:
{
  users.users.sean = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "video"
      "audio"
      "networkmanager"
    ];
    hashedPasswordFile = "/home/sean/.secrets/password.txt";
  };

  home-manager.users.sean = {
    imports = [
      inputs.sops-nix.homeManagerModules.sops
      ../features/core/secrets/sops.nix
      ../features/core/btop.nix
      ../features/core/fastfetch.nix
      ../features/desktop/dev/neovim.nix
    ];

    home = {
      username = "sean";
      homeDirectory = "/home/sean";
      stateVersion = "26.11";
    };

    sops.secrets."ssh_key" = {
      path = "/home/sean/.sops/ssh_key";
      mode = "0600";
    };

    programs.git.settings.user = {
      name = "sean tietz";
      email = "sean.tietz2@gmail.com";
    };
  };
}
