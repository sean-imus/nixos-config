{ ... }:
{
  flake.modules.homeManager.games =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        mindustry
        the-powder-toy
        ddnet
      ];
    };
}
