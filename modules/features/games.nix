{
  flake.modules.homeManager.games =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.the-powder-toy
        pkgs.ddnet
      ];
    };
}
