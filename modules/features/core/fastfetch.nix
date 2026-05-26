{ ... }:
{
  flake.modules.homeManager.fastfetch = {
    home.shellAliases = {
      ff = "fastfetch";
    };

    programs.fastfetch = {
      enable = true;
      settings = {
        modules = [
          "title"
          "chassis"
          "datetime"
          "separator"
          "os"
          "host"
          "kernel"
          "uptime"
          "packages"
          "shell"
          "de"
          "wm"
          "monitor"
          "terminal"
          "editor"
          "cpu"
          "gpu"
          "memory"
          "swap"
          "disk"
        ];
      };
    };
  };
}
