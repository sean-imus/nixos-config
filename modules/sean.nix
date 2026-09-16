{ inputs, pkgs, ... }:
let
  theme = import ./lib/theme.nix;
in
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

  programs.fish = {
    enable = true;
    generateCompletions = false;
  };
  users.users.sean.shell = pkgs.fish;

  home-manager.users.sean = {
    imports = [
      inputs.nix-index-database.homeModules.default
      inputs.sops-nix.homeManagerModules.sops
      ./features/bar.nix
      ./features/browser.nix
      ./features/btop.nix
      ./features/editor.nix
      ./features/fastfetch.nix
      ./features/file-manager.nix
      ./features/gaming.nix
      ./features/git.nix
      ./features/launcher.nix
      ./features/mime.nix
      ./features/notifications
      ./features/office.nix
      ./features/omp.nix
      ./features/opencode.nix
      ./features/rebuild.nix
      ./features/secrets/sops.nix
      ./features/shell.nix
      ./features/soteria.nix
      ./features/ssh.nix
      ./features/terminal.nix
      ./features/wallpaper.nix
    ];

    home = {
      username = "sean";
      homeDirectory = "/home/sean";
      stateVersion = "26.11";
    };

    programs.nix-index-database.comma.enable = true;
    programs.nix-index.enableFishIntegration = false;

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
        name = theme.fontFamily;
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
  };
}
