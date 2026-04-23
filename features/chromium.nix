{ ... }:

{
  nixosModule = {};

  homeManagerModule = {
    programs.chromium = {
      enable = true;
      extensions = [
        "ddkjiahejlhfcafbddmgiahcphecmpfh" # uBlock Origin Lite
      ];
    };
  };
}