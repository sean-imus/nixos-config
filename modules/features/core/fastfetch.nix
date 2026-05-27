{ inputs, ... }:
{
  flake-file.inputs.areofyl-fetch = {
    url = "github:areofyl/fetch";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.homeManager.fastfetch =
    { ... }:
    {
      imports = [ inputs.areofyl-fetch.homeManagerModules.default ];

      home.shellAliases = {
        ff = "fetch --infinite";
      };

      programs.fetch = {
        enable = true;
        info = [
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
          "display"
          "wm"
          "shell"
          "colors"
        ];
        spin = "xy";
        speed = 1.0;
      };
    };
}
