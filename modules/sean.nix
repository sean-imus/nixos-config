{ inputs, pkgs, ... }:
{
  users.users.sean = {
    isNormalUser = true;
    hashedPasswordFile = "/home/sean/.secrets/password.txt";
    extraGroups = [
      "wheel"
      "video"
      "audio"
      "networkmanager"
      "wpa_supplicant"
    ];
  };

  programs.zsh.enable = true;
  users.users.sean.shell = pkgs.zsh;

  home-manager.users.sean = {
    imports = [
      inputs.sops-nix.homeManagerModules.sops
      ./features/secrets/sops.nix
      ./features/ssh.nix
      ./features/git.nix
      ./features/shell.nix
      ./features/shell-tools.nix
      ./features/btop.nix
      ./features/fastfetch.nix
      ./features/editor.nix
      ./features/opencode.nix
      ./features/terminal.nix
      ./features/launcher.nix
      ./features/bar.nix
      ./features/theming.nix
      ./features/office.nix
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
