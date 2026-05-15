{ inputs, ... }:
{
  flake-file.inputs = {
    nix-firefox-addons = {
      url = "github:OsiPog/nix-firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.modules.homeManager.firefox =
    { pkgs, config, ... }:
    {
      programs.firefox = {
        enable = true;
        configPath = "${config.xdg.configHome}/mozilla/firefox";
        profiles.${config.home.username} = {
          settings = {
	    "app.normandy.first_run" = false;
            "extensions.autoDisableScopes" = 0;
            "browser.startup.homepage" = "about:newtab";
	    "browser.aboutConfig.showWarning" = false;
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
          };
          extensions = {
            force = true;
            packages = [
              inputs.nix-firefox-addons.addons.${pkgs.stdenv.hostPlatform.system}.ublock-origin
              inputs.nix-firefox-addons.addons.${pkgs.stdenv.hostPlatform.system}.vimium-ff
              inputs.nix-firefox-addons.addons.${pkgs.stdenv.hostPlatform.system}.dictionary-german
            ];
          };
        };
      };
    };
}
