{ inputs, ... }:
{
  flake-file.inputs.nix-firefox-addons = {
    url = "github:OsiPog/nix-firefox-addons";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.homeManager.desktop =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      startPage = "file://${./_start-page.html}";
      sys = pkgs.stdenv.hostPlatform.system; # so we use the correct cpu architecture for our extensions below

      extPackages = [
        inputs.nix-firefox-addons.addons.${sys}.ublock-origin
        inputs.nix-firefox-addons.addons.${sys}.vimium-ff
      ];

      extensions = {
        force = true;
        packages = extPackages;
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

      commonSettings = {
        "app.normandy.first_run" = false;
        "extensions.autoDisableScopes" = 0;
        "browser.startup.homepage" = startPage;
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

      mkProfile =
        {
          isDefault ? false,
          id ? 0,
          ...
        }@args:
        {
          inherit
            isDefault
            extensions
            bookmarks
            id
            ;
          settings =
            commonSettings
            // builtins.removeAttrs args [
              "isDefault"
              "id"
            ];
        };

      firefoxPkg = config.programs.firefox.finalPackage;
      installsHash = builtins.substring 0 12 (
        builtins.hashString "sha256" (lib.toLower "${firefoxPkg}/bin")
      );
    in
    {
      home.file."${config.programs.firefox.configPath}/installs.ini" = {
        text = ''
          [${installsHash}]
          Default=private
        '';
      };

      #TODO fix the ugly code above, its a bandage that isnt even working completely

      home.packages = with pkgs; [
        hunspellDicts.en_US
        hunspellDicts.de_DE
      ];

      home.sessionVariables.DICPATH = lib.makeSearchPath "share/hunspell" [
        pkgs.hunspellDicts.en_US
        pkgs.hunspellDicts.de_DE
      ];
      #TODO sometimes the above code works for setting autocorrect languages, on some sites not -> check if its a website issue or an issue with the code

      programs.niri.settings.binds."Mod+B".action.spawn = "firefox";

      persist.directories = [ ".mozilla/firefox" ];
      # one day we will get a better solution for not needing to log into every site on reboot, #TODO explore password managers as a workaround

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

        profiles = {
          work = mkProfile { id = 0; };
          school = mkProfile { id = 1; };
          private = mkProfile {
            id = 2;
            isDefault = true;
          };
        };
      };
    };
}
