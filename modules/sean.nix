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

  programs.fish.enable = true;
  users.users.sean.shell = pkgs.fish;

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
      ./features/shell.nix
      ./features/ssh.nix
      ./features/terminal.nix
    ];

    home = {
      username = "sean";
      homeDirectory = "/home/sean";
      stateVersion = "26.11";
    };

    gtk = {
      enable = true;
      theme = {
        name = "everforest-dark-medium";
        package = pkgs.everforest-gtk-theme;
      };
      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };
      font = {
        name = "JetBrainsMono Nerd Font";
        size = 10;
      };
    };

    home.pointerCursor = {
      enable = true;
      name = "everforest-cursors";
      package = pkgs.everforest-cursors;
      size = 24;
      gtk.enable = true;
    };

    sops.secrets."ssh_key" = {
      path = "/home/sean/.sops/ssh_key";
      mode = "0600";
    };

  };
}
