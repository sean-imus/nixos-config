{ inputs, ... }:
{
  flake.modules.homeManager.sean =
    { pkgs, config, ... }:
    {
      imports = with inputs.self.modules.homeManager; [
        alacritty
        btop
        firefox
        git
        mcp
        neovim
        niri
        opencode
        printing
        rdp-work
        shell
        ssh
        vesktop
        vscode
      ];

      home.username = "sean";
      home.homeDirectory = "/home/${config.home.username}";

      programs.git = {
        settings.user = {
          name = "sean tietz";
          email = "sean.tietz2@gmail.com";
        };
      };

      home.packages = with pkgs; [
        libreoffice
        spotify
        nixfmt-tree
        nixfmt
        nixd
      ];

      home.stateVersion = "25.11";
    };
}
