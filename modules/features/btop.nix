{ lib, ... }:
{
  flake.modules.nixos.btop = {
    options.userCfg.btop.enable = lib.mkEnableOption "btop system monitor";
  };

  flake.modules.homeManager.btop = {
    programs.btop = {
      enable = true;
      settings = {
        update_ms = 100;
        theme_background = false;
      };
    };
  };
}
