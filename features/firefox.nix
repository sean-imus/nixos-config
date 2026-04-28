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
          "browser.startup.homepage" = "about:profiles";
          "browser.bookmarks.addedImportButton" = false;
          "browser.shell.checkDefaultBrowser" = false;
          "browser.toolbars.bookmarks.visibility" = "always";
        };
        extensions = {
          force = true;
          packages = with pkgs.firefoxAddons; [
            ublock-origin
          ];
        };
        bookmarks = {
          force = true;
          settings = [
            {
              toolbar = true;
              bookmarks = [
                {
                  name = "NixOS";
                  bookmarks = [
                    {
                      name = "NixOS Search";
                      url = "https://search.nixos.org/packages?channel=unstable&include_modular_service_options=1&include_nixos_options=1";
                    }
                    {
                      name = "Home-Manager Search";
                      url = "https://home-manager-options.extranix.com/?query=&release=master";
                    }
                    {
                      name = "Niri Wiki";
                      url = "https://niri-wm.github.io/niri/";
                    }
                  ];
                }
              ];
            }
          ];
        };
      };
    };
  };
}
