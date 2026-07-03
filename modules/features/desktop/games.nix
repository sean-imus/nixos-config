{ ... }:
{
  flake.modules.homeManager.desktop =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        mindustry
        the-powder-toy
        ddnet
      ];
    };
}
