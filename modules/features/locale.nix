{
  flake.modules.nixos.locale = {
    time.timeZone = "Europe/Berlin";

    i18n = {
      defaultLocale = "en_US.UTF-8";
      extraLocaleSettings = {
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
    };

    console.keyMap = "de-latin1";

    services.xserver.xkb = {
      layout = "de";
      options = "caps:escape";
    };

    environment.variables = {
      XKB_DEFAULT_LAYOUT = "de";
      XKB_DEFAULT_OPTIONS = "caps:escape";
      XKB_DEFAULT_VARIANT = "";
    };
  };
}
