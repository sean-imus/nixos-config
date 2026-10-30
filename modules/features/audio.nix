{
  den.aspects.audio.nixos = {
    services.pipewire = {
      enable = true;
      pulse.enable = true;
      alsa.enable = true;
    };

    security.rtkit.enable = true;
  };
}
