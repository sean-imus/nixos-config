{ inputs, pkgs, ... }:
{
  programs.zsh.enable = true;

  users.users.sean = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "video"
      "audio"
      "networkmanager"
    ];
    shell = pkgs.zsh;
    hashedPasswordFile = "/home/sean/.secrets/password.txt";
  };

  home-manager.users.sean = {
    imports = [
      inputs.sops-nix.homeManagerModules.sops
      ./features/secrets/sops.nix
      ./features/core/ssh.nix
      ./features/core/git.nix
      ./features/core/zsh.nix
      ./features/core/shell-tools.nix
      ./features/core/btop.nix
      ./features/core/fastfetch.nix
      ./features/desktop/dev/neovim.nix
      ./features/desktop/dev/opencode.nix
      ./features/desktop/kitty.nix
      ./features/desktop/launcher.nix
      ./features/desktop/bar.nix
      ./features/desktop/theming.nix
      ./features/desktop/office.nix
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

  };
}
