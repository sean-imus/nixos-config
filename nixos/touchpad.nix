# =============================================================================
# TOUCHPAD MODULE - Touchpad configuration
# =============================================================================

{ config, lib, ... }:

{
  options = { };

  config = {
    # Enable libinput for touchpad support
    services.libinput.enable = true;
  };
}