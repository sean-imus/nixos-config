{ inputs, ... }:
{
  flake-file.inputs = {
    nix-firefox-addons = {
      url = "github:OsiPog/nix-firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.modules.homeManager.firefox =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    {
      home.packages = with pkgs; [
        hunspellDicts.en_US
        hunspellDicts.de_DE
      ];

      home.sessionVariables.DICPATH = lib.makeSearchPath "share/hunspell" [
        pkgs.hunspellDicts.en_US
        pkgs.hunspellDicts.de_DE
      ];

      programs.firefox = {
        enable = true;
        configPath = "${config.xdg.configHome}/mozilla/firefox";

        policies = {
          DisableProfileImport = true;
          OverrideFirstRunPage = "";
          OverridePostUpdatePage = "";
          SkipTermsOfUse = true;
          DontCheckDefaultBrowser = true;
          DisableTelemetry = true;
          DisableFirefoxStudies = true;
          DisablePocket = true;
          UserMessaging = {
            ExtensionRecommendations = false;
            FeatureRecommendations = false;
            UrlbarInterventions = false;
            SkipOnboarding = true;
            MoreFromMozilla = false;
            FirefoxLabs = false;
          };
          FirefoxHome = {
            Search = true;
            TopSites = false;
            SponsoredTopSites = false;
            Highlights = false;
            Snippets = false;
          };
        };

        profiles.${config.home.username} = {
          settings = {
            "app.normandy.first_run" = false;
            "extensions.autoDisableScopes" = 0;
            "browser.startup.homepage" = "about:newtab";
            "browser.aboutConfig.showWarning" = false;
            "browser.aboutwelcome.didSeeFinalScreen" = true;
            "trailhead.firstrun.didSeeAboutWelcome" = true;
            "doh-rollout.doneFirstRun" = true;
            "browser.bookmarks.addedImportButton" = false;
            "browser.shell.checkDefaultBrowser" = false;
            "browser.toolbars.bookmarks.visibility" = "always";
            "signon.rememberSignons" = false;
            "browser.newtabpage.activity-stream.feeds.topsites" = false;
            "browser.newtabpage.activity-stream.showSponsoredCheckboxes" = false;
            "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
            "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
            "sidebar.visibility" = "hide-sidebar";
            "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" = false;
            "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false;
            "spellchecker.dictionary" = "en-US,de-DE";
            "datareporting.policy.dataSubmissionPolicyBypassNotification" = true;
            "datareporting.policy.dataSubmissionPolicyNotifiedTime" = 9999999999999;
            "browser.migration.didMigrate" = true;
            "startup.homepage_welcome_url" = "";
            "startup.homepage_welcome_url.additional" = "";
            "browser.uitour.enabled" = false;
            "browser.disableResetPrompt" = true;
            "browser.laterrun.enabled" = false;
          };
          extensions = {
            force = true;
            packages = [
              inputs.nix-firefox-addons.addons.${pkgs.stdenv.hostPlatform.system}.ublock-origin
              inputs.nix-firefox-addons.addons.${pkgs.stdenv.hostPlatform.system}.vimium-ff
            ];
          };
        };
      };
    };
}
