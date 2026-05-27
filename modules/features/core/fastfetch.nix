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
          "cpu"
          "gpu"
          "memory"
          "swap"
          "disk"
          "monitor"
          "de"
          "wm"
          "shell"
          "terminal"
          "editor"
        ];
      };
    };
  };
}
