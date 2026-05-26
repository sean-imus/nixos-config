{ lib, ... }:
{
  flake.modules.nixos.fastfetch = {
    options.userCfg.fastfetch.enable = lib.mkEnableOption "fastfetch system info";
  };

  flake.modules.homeManager.fastfetch = {
    home.shellAliases = {
      ff = "fastfetch";
    };

    programs.fastfetch = {
      enable = true;
      settings = {
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
