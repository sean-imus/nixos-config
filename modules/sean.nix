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

  programs.fish = {
    enable = true;
    generateCompletions = false;
  };
  users.users.sean.shell = pkgs.fish;

  home-manager.users.sean = {
    imports = [
      inputs.nix-index-database.homeModules.default
      ./features/appearance.nix
      ./features/browser.nix
      ./features/btop.nix
      ./features/editor.nix
      ./features/fastfetch.nix
      ./features/file-manager.nix
      ./features/gaming.nix
      ./features/git.nix
      ./features/launcher.nix
      ./features/mcp.nix
      ./features/mime.nix
      ./features/office.nix
      ./features/quickshell
      ./features/shell.nix
      ./features/terminal.nix
      ./features/theme.nix
      ./features/wallpaper.nix
    ];

    home = {
      username = "sean";
      homeDirectory = "/home/sean";
      stateVersion = "26.11";
    };

    programs.nix-index-database.comma.enable = true;
    programs.nix-index.enableFishIntegration = false;
  };
}
