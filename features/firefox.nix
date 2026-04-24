{ pkgs, config, ... }:

{
  nixosModule = { };

  homeManagerModule = {
    programs.firefox = {
      enable = true;
      configPath = "${config.xdg.configHome}/mozilla/firefox";
      profiles.sean = {
        settings = {
          "extensions.autoDisableScopes" = 0;
        };
        extensions = {
          packages = with pkgs.firefoxAddons; [
            ublock-origin
          ];
        };
      };
    };
  };
}
