{ inputs, ... }:
{
  flake-file.inputs.nix-firefox-addons = {
    url = "github:OsiPog/nix-firefox-addons";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.homeManager.browser =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      # Served via darkhttpd so new-tab-override gets a valid http:// URL.
      # Firefox rejects file:// in extension-controlled new tab redirects.
      startPageUrl = "http://127.0.0.1:8765/";
      startPageDir = pkgs.runCommand "firefox-startpage" { } ''
        mkdir $out
        cp ${./_start-page.html} $out/index.html
      '';
      sys = pkgs.stdenv.hostPlatform.system;
    in
    {
      home.packages = with pkgs; [
        hunspellDicts.en_US
        hunspellDicts.de_DE
      ];

      home.sessionVariables.DICPATH = lib.makeSearchPath "share/hunspell" [
        pkgs.hunspellDicts.en_US
        pkgs.hunspellDicts.de_DE
      ];

      systemd.user.services.firefox-startpage = {
        Unit = {
          Description = "Firefox start page server";
          After = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${pkgs.darkhttpd}/bin/darkhttpd ${startPageDir} --port 8765 --addr 127.0.0.1";
          Restart = "on-failure";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };

      programs.firefox = {
        enable = true;
        configPath = ".mozilla/firefox";

        policies = {
          DisableProfileImport = true;
          OverrideFirstRunPage = "";
          OverridePostUpdatePage = "";
          SkipTermsOfUse = true;
          DontCheckDefaultBrowser = true;
          DisableTelemetry = true;
          DisableFirefoxStudies = true;
          DisablePocket = true;
          DefaultSearchService = "DuckDuckGo";
          "3rdparty".Extensions."newtaboverride@agenedia.com" = {
            type = "custom_url";
            url = startPageUrl;
          };
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
            "browser.startup.homepage" = startPageUrl;
            "browser.aboutConfig.showWarning" = false;
            "browser.aboutwelcome.didSeeFinalScreen" = true;
            "trailhead.firstrun.didSeeAboutWelcome" = true;
            "doh-rollout.doneFirstRun" = true;
            "browser.download.dir" = config.home.homeDirectory;
            "browser.download.useDownloadDir" = false;
            "browser.download.always_ask_before_handling" = true;
            "browser.bookmarks.addedImportButton" = false;
            "browser.shell.checkDefaultBrowser" = false;
            "browser.toolbars.bookmarks.visibility" = "always";
            "signon.rememberSignons" = false;
            "browser.newtabpage.activity-stream.feeds.topsites" = false;
            "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
            "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
            "sidebar.visibility" = "hide-sidebar";
            "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" = false;
            "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false;
            "spellchecker.dictionary" = "en-US,de-DE";
            "datareporting.policy.dataSubmissionPolicyBypassNotification" = true;
            "browser.migration.didMigrate" = true;
            "startup.homepage_welcome_url" = "";
            "browser.uitour.enabled" = false;
            "browser.disableResetPrompt" = true;
            "browser.laterrun.enabled" = false;
          };

          extensions = {
            force = true;
            packages = [
              inputs.nix-firefox-addons.addons.${sys}.ublock-origin
              inputs.nix-firefox-addons.addons.${sys}.vimium-ff
              inputs.nix-firefox-addons.addons.${sys}.new-tab-override
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
                        name = "Admin Center";
                        url = "https://admin.cloud.microsoft/";
                      }
                      {
                        name = "Sophos";
                        url = "https://central.sophos.com/manage/overview/dashboard";
                      }
                      {
                        name = "Swyx";
                        url = "https://www.swyxon.com/ControlCenter";
                      }
                      {
                        name = "Email Tracking";
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
                        name = "Photopea";
                        url = "https://www.photopea.com/";
                      }
                      {
                        name = "Remove.bg";
                        url = "https://www.remove.bg/";
                      }
                      {
                        name = "Draw.io";
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
