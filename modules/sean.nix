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
    ];
  };

  programs.zsh.enable = true;
  users.users.sean.shell = pkgs.zsh;

  home-manager.users.sean = {
    imports = [
      inputs.sops-nix.homeManagerModules.sops
      ./features/bar.nix
      ./features/browser.nix
      ./features/btop.nix
      ./features/editor.nix
      ./features/fastfetch.nix
      ./features/git.nix
      ./features/launcher.nix
      ./features/niri/utilities.nix
      ./features/office.nix
      ./features/opencode.nix
      ./features/secrets/sops.nix
      ./features/shell-tools.nix
      ./features/shell.nix
      ./features/ssh.nix
      ./features/terminal.nix
      ./features/theming.nix
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
