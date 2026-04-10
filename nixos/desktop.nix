# =============================================================================
# DESKTOP MODULE - Display manager and desktop environment
# =============================================================================
#
# Configures:
# - X server
# - GDM (GNOME Display Manager)
# - GNOME desktop environment
# =============================================================================

{
  config,
  lib,
  pkgs,
  ...
}:

{
  options = { };

  config = {
    # Enable X server
    services.xserver.enable = true;

    # Enable GDM (GNOME login screen)
    services.displayManager.gdm.enable = true;

    # Enable GNOME desktop
    services.desktopManager.gnome.enable = true;
  };
}
