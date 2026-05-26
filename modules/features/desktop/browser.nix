{ inputs, lib, ... }:
{
  flake.modules.nixos.browser = { config, ... }: {
    options.userCfg.browser.enable = lib.mkEnableOption "Firefox web browser";
    config = lib.mkIf config.userCfg.browser.enable {
      home-manager.users.sean.imports = [ inputs.self.modules.homeManager.browser ];
    };
  };

  flake-file.inputs = {
    nix-firefox-addons = {
      url = "github:OsiPog/nix-firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.modules.homeManager.browser =
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
            "browser.download.dir" = "/home/${config.home.username}/";
            "browser.download.useDownloadDir" = false;
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
                        url = "https://search.nixos.org/options?channel=unstable&include_home_manager_options=1&include_modular_service_options=1&include_nixos_options=1";
                      }
                      {
                        name = "Niri Wiki";
                        url = "https://niri-wm.github.io/niri/";
                      }
                    ];
                  }
                  {
                    name = "Work";
                    bookmarks = [
                      {
                        name = "Outlook";
                        url = "https://outlook.cloud.microsoft/mail/";
                      }
                      {
                        name = "Teams";
                        url = "https://teams.cloud.microsoft/";
                      }
                      {
                        name = "To-Do";
                        url = "https://app.fizzy.do/6172759/boards/03fqfadkang7940o21lqrzl2e/columns/stream";
                      }
                      {
                        name = "Copilot";
                        url = "https://m365.cloud.microsoft/chat";
                      }
                      {
                        name = "Microsoft Admin Center";
                        url = "https://admin.cloud.microsoft/";
                      }
                      {
                        name = "Sophos Admin Center";
                        url = "https://central.sophos.com/manage/overview/dashboard";
                      }
                      {
                        name = "Swyx Control Center";
                        url = "https://www.swyxon.com/ControlCenter";
                      }
                      {
                        name = "E-Mail Live Tracking";
                        url = "https://ms.hees.de/email_security/email_livetracking";
                      }
                      {
                        name = "EinfachGast";
                        url = "https://mein.einfachgast.de/live";
                      }
                    ];
                  }
                  {
                    name = "Tools";
                    bookmarks = [
                      {
                        name = "Photo Editor";
                        url = "https://www.photopea.com/";
                      }
                      {
                        name = "Background Remover";
                        url = "https://www.remove.bg/";
                      }
                      {
                        name = "Graph Maker";
                        url = "https://app.diagrams.net/";
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
