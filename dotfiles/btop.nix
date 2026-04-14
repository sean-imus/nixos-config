{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.btop = {
    enable = true;
    settings = {
      update_ms = 100;
    };
  };
}
