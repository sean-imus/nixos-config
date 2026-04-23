{ pkgs, ... }:

{
  nixosModule = { };

  homeManagerModule = {
    programs.firefox = {
      enable = true;
      profiles.sean = {
        settings = {
          "extensions.autoDisableScopes" = 0;
        };
        extensions.packages = with pkgs.firefoxAddons; [
          ublock-origin
        ];
      };
    };
  };
}