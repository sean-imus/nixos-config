{ inputs, ... }:
{
  flake-file.inputs = {
    nix-firefox-addons = {
      url = "github:OsiPog/nix-firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vimium-options = {
      url = "github:uimataso/vimium-nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.modules.nixos.firefox = {
    nixpkgs.overlays = [ inputs.nix-firefox-addons.overlays.default ];
  };

  flake.modules.homeManager.firefox =
    { pkgs, config, ... }:
    {
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
        profiles.${config.home.username} = {
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
        };
      };
    };
}
