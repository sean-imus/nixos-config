{ config, ... }: {
  flake.modules.homeManager.firefox = { pkgs, config, ... }: {
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
      nextPatterns = "";
      previousPatterns = "";
      searchEngines = { };
      userDefinedLinkHintCss = "";
      exclusionRules = [ ];

      scrollStepSize = 60;
      smoothScroll = true;
      filterLinkHints = false;
      waitForEnterForFilteredHints = true;
      hideHud = false;
      regexFindMode = false;
      ignoreKeyboardLayout = false;
      newTabUrl = "about:newtab";
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
          "signon.rememberSignons" = false;
          "browser.newtabpage.activity-stream.feeds.topsites" = false;
          "browser.newtabpage.activity-stream.showSponsoredCheckboxes" = false;
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
          "sidebar.visibility" = "hide-sidebar";
          "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" = false;
          "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false;
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
                    { name = "NixOS Search"; url = "https://search.nixos.org/options?channel=unstable&include_home_manager_options=1&include_modular_service_options=1&include_nixos_options=1"; }
                    { name = "Niri Wiki"; url = "https://niri-wm.github.io/niri/"; }
                  ];
                }
                {
                  name = "Work";
                  bookmarks = [
                    { name = "Outlook"; url = "https://outlook.cloud.microsoft/mail/"; }
                    { name = "Teams"; url = "https://teams.cloud.microsoft/"; }
                    { name = "To-Do"; url = "https://app.fizzy.do/6172759/boards/03fqfadkang7940o21lqrzl2e/columns/stream"; }
                    { name = "Copilot"; url = "https://m365.cloud.microsoft/chat"; }
                    { name = "Microsoft Admin Center"; url = "https://admin.cloud.microsoft/"; }
                    { name = "Sophos Admin Center"; url = "https://central.sophos.com/manage/overview/dashboard"; }
                    { name = "Swyx Control Center"; url = "https://www.swyxon.com/ControlCenter"; }
                    { name = "E-Mail Live Tracking"; url = "https://ms.hees.de/email_security/email_livetracking"; }
                  ];
                }
                {
                  name = "Tools";
                  bookmarks = [
                    { name = "Photo Editor"; url = "https://www.photopea.com/"; }
                    { name = "Graph Maker"; url = "https://app.diagrams.net/"; }
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
