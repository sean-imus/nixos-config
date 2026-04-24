{ pkgs, config, ... }:

{
  nixosModule = { };

  homeManagerModule = {
    programs.firefox = {
      enable = true;
      configPath = "${config.xdg.configHome}/mozilla/firefox";
      profiles.sean = {
        settings = {
          "extensions.autoDisableScopes" = 0;
        };
        extensions = {
          packages = with pkgs.firefoxAddons; [
            ublock-origin
          ];
        };
	bookmarks = {
	  force = true;
	  settings = [
	    {
	      name = "NixOS";
	      toolbar = true;
	      bookmarks = [
	        { name = "NixOS Search"; url = "https://search.nixos.org/packages"; }
	        { name = "Home-Manager Search"; url = "https://home-manager-options.extranix.com/?query=&release=master"; }
	      ];
	    }
	  ];
	};
      };
    };
  };
}
