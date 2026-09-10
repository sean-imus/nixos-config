{ pkgs, ... }:
{
  programs.firefox = {
    enable = true;

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
        "{d7742d87-e61d-4b78-b8a1-b469842139fa}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/vimium-ff/latest.xpi";
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
