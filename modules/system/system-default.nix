{ ... }:
{
  flake.modules.nixos.systemDefault =
    { ... }:
    {
      time.timeZone = "Europe/Berlin";
      i18n.defaultLocale = "en_US.UTF-8";
      i18n.extraLocaleSettings = {
        LC_ADDRESS = "de_DE.UTF-8";
        LC_IDENTIFICATION = "de_DE.UTF-8";
        LC_MEASUREMENT = "de_DE.UTF-8";
        LC_MONETARY = "de_DE.UTF-8";
        LC_NAME = "de_DE.UTF-8";
        LC_NUMERIC = "de_DE.UTF-8";
        LC_PAPER = "de_DE.UTF-8";
        LC_TELEPHONE = "de_DE.UTF-8";
        LC_TIME = "de_DE.UTF-8";
      };

      environment.variables = {
        XKB_DEFAULT_LAYOUT = "de";
        XKB_DEFAULT_VARIANT = "";
      };

      console.keyMap = "de-latin1";
      services.xserver.xkb.layout = "de";

      nixpkgs.config.allowUnfree = true;

      nix = {
        settings = {
          auto-optimise-store = true;
          download-buffer-size = 536870912;
          experimental-features = [
            "nix-command"
            "flakes"
          ];
        };
        gc = {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-than 7d";
        };
        optimise = {
          automatic = true;
          dates = "weekly";
        };
      };

      system.stateVersion = "25.11";
      nixpkgs.hostPlatform = "x86_64-linux";
    };
}
