# =============================================================================
# SOUND MODULE - Audio configuration
# =============================================================================
#
# Configures:
# - PipeWire (modern audio server)
# - ALSA compatibility
# - PulseAudio compatibility mode
# =============================================================================

{ config, lib, ... }:

{
  options = { };

  config = {
    # Disable PulseAudio (we use PipeWire)
    services.pulseaudio.enable = false;

    # Enable rtkit (real-time priority for audio)
    security.rtkit.enable = true;

    # PipeWire configuration
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };
}
