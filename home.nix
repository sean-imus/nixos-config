{ config, pkgs, ... }:

{

  # Dotfile Import
  imports = [
    ./dotfiles/btop.nix
  ];

  home.username = "sean";
  home.homeDirectory = "/home/sean";

  # User Packages
  home.packages = with pkgs; [
    fastfetch
    lazygit
    libreoffice
    opencode
    nixfmt-tree
  ];

  # Options
  programs.chromium = {
    enable = true;
    extensions = [
      "ddkjiahejlhfcafbddmgiahcphecmpfh" # uBlock Origin Lite
    ];
  };

  programs.git = {
    enable = true;
    settings = {
      user = {
        Name = "Sean Tietz";
        Email = "sean.tietz2@gmail.com";
      };
    };
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false; # Silence Warning
    matchBlocks = {
      "github.com" = {
        user = "git";
        identityFile = "~/.ssh/id_ed25519";
      };
    };
  };

  programs.alacritty = {
    enable = true;
    settings = {
      env.TERM = "xterm-256color";
      font = {
        size = 12;
      };
      scrolling.multiplier = 5;
      selection.save_to_clipboard = true;
    };
  };

  programs.bash = {
    enable = true;
    shellAliases = {
      lg = "lazygit";
      c = "opencode";
    };
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    withRuby = false; # Silence Warning
    withPython3 = false; # Silence Warning
  };

  # Don't touch!
  home.stateVersion = "25.11";
}
