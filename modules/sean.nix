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
    shell = pkgs.fish;
  };

  programs.fish = {
    enable = true;
    generateCompletions = false;
  };

  home-manager.users.sean = {
    imports = [
      inputs.nix-index-database.homeModules.default
      ./features/apps.nix
      ./features/browser.nix
      ./features/desktop-entries.nix
      ./features/editor.nix
      ./features/file-manager.nix
      ./features/git.nix
      ./features/launcher.nix
      ./features/quickshell
      ./features/shell.nix
      ./features/terminal.nix
      ./features/theme.nix
    ];

    home.stateVersion = "26.11";

    programs.nix-index-database.comma.enable = true;
    programs.nix-index.enableFishIntegration = false;
  };
}
