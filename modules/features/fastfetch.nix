{ inputs, ... }:
let
  logoPath = "${inputs.self}/assets/nixos.gif";
in
{
  flake.modules.homeManager.fastfetch = {
    home.shellAliases = {
      ff = "fastfetch";
    };

    programs.fastfetch = {
      enable = true;
      settings = {
        logo = {
          source = logoPath;
          type = "kitty-icat";
          width = 30;
        };
        modules = [
          "title"
          "separator"
          "os"
          "host"
          "kernel"
          "uptime"
          "packages"
          "shell"
          "de"
          "wm"
          "terminal"
          "terminal_font"
          "cpu"
          "gpu"
          "memory"
          "storage"
        ];
      };
    };
  };
}
