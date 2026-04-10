# =============================================================================
# LOCALE MODULE - Internationalization and keyboard
# =============================================================================
#
# Configures:
# - Time zone
# - System locale
# - Keyboard layout (console and X11)
# =============================================================================

{ config, lib, ... }:

{
  options = { };

  config = {
    # Time zone: Berlin (German standard time)
    time.timeZone = "Europe/Berlin";

    # Default locale: US English UTF-8
    i18n.defaultLocale = "en_US.UTF-8";

    # Additional locale settings (German formats)
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

    # X11 keyboard layout (German)
    services.xserver.xkb = {
      layout = "de";
      variant = "";
    };

    # Console keymap (German)
    console.keyMap = "de";
  };
}
