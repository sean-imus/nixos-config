{
  pkgs,
  config,
  ...
}:

{
  imports = [
    (import ./features/btop.nix { }).homeManagerModule
    (import ./features/firefox.nix { inherit pkgs config; }).homeManagerModule
    (import ./features/git.nix { }).homeManagerModule
    (import ./features/ssh.nix { }).homeManagerModule
    (import ./features/alacritty.nix { }).homeManagerModule
    (import ./features/neovim.nix { inherit pkgs; }).homeManagerModule
    (import ./features/opencode.nix { inherit pkgs; }).homeManagerModule
    (import ./features/network-tools.nix { inherit pkgs; }).homeManagerModule
    (import ./features/niri/niri.nix { inherit pkgs; }).homeManagerModule
    (import ./features/rdp-work.nix { inherit pkgs; }).homeManagerModule
    (import ./features/printing.nix { inherit pkgs; }).homeManagerModule
    (import ./features/vscode.nix { inherit pkgs config; }).homeManagerModule
    (import ./features/vesktop.nix { }).homeManagerModule
    (import ./features/mcp.nix { inherit pkgs; }).homeManagerModule
    (import ./features/shell.nix { }).homeManagerModule
  ];

  home.username = "sean";
  home.homeDirectory = "/home/sean";

  # User Packages
  home.packages = with pkgs; [
    libreoffice
    nixfmt-tree # treefmt
    nixfmt
    nixd
    spotify
  ];

  # Don't Touch!
  home.stateVersion = "25.11";
}
