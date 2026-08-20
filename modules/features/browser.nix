{ pkgs, ... }:
{
  programs.firefox = {
    enable = true;
    package = pkgs.firefox;

    policies = {
      DisableTelemetry = true;
      DisablePocket = true;
      DisableFirefoxAccounts = true;
      OfferToSaveLogins = false;
      PasswordManagerEnabled = false;
      ExtensionSettings = {
        "uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "normal_installed";
        };
      };
    };

    profiles.default = {
      isDefault = true;

      search.force = true;
      containersForce = true;
      extensions.force = true;
      handlers.force = true;

      settings = {
        "browser.startup.homepage_override.once" = "about:home";
        "browser.newtabpage.enabled" = true;
        "browser.tabs.tabmanager.enabled" = true;
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "browser.compactmode.show" = true;
        "general.smoothScroll" = true;
      };
    };
  };
}
