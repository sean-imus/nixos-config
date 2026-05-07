{ pkgs, config, ... }:

{
  nixosModule = { };

  homeManagerModule = {
    # Declarative Vimium Settings
    home.vimiumOptions = {
      enable = true;
      outputFilePath = ".config/vimium-options.json";

      grabBackFocus = true;
      linkHintCharacters = "asdqweyxcrfvtgb";

      keyMappings = {
        unmapAll = true;
        map = {
          f = "LinkHints.activateMode";
          d = "scrollDown";
          u = "scrollUp";
          gi = "focusInput";
        };
      };

      scrollStepSize = 60;
      smoothScroll = true;
      filterLinkHints = false;
      waitForEnterForFilteredHints = true;
      hideHud = false;
      regexFindMode = false;
      ignoreKeyboardLayout = false;
      previousPatterns = "prev,previous,back,<,‹,←,«,≪,<<";
      nextPatterns = "next,more,>,›,→,»,≫,>>";
      newTabUrl = "about:newtab";
      exclusionRules = [
        {
          pattern = "https?://mail.google.com/*";
          passKeys = "";
        }
      ];
    };

    programs.firefox = {
      enable = true;
      configPath = "${config.xdg.configHome}/mozilla/firefox";
      profiles.sean = {
        settings = {
          "extensions.autoDisableScopes" = 0;
          "browser.startup.homepage" = "about:newtab";
          "browser.bookmarks.addedImportButton" = false;
          "browser.shell.checkDefaultBrowser" = false;
          "browser.toolbars.bookmarks.visibility" = "always";
          "signon.rememberSignons" = false; # Don't Ask to Save Passwords
          "browser.newtabpage.activity-stream.feeds.topsites" = false; # No Shortcuts on New Page
          "browser.newtabpage.activity-stream.showSponsoredCheckboxes" = false; # Don't Show Sponsored Shortcuts
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = false; # Don't Show Sponsored Shortcuts
          "sidebar.visibility" = "hide-sidebar";
          "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" = false; # Don't Recommend Features
          "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false; # Don't Recommend Addons
        };
        extensions = {
          force = true;
          packages = with pkgs.firefoxAddons; [
            ublock-origin
            vimium-ff
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
                  ];
                }
                {
                  name = "Tools";
                  bookmarks = [
                    {
                      name = "Photo Editor";
                      url = "https://www.photopea.com/";
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
