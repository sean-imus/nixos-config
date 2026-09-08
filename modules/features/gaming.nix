{ pkgs, ... }:
{
  home.packages = with pkgs; [
    the-powder-toy
    ddnet
  ];
}
