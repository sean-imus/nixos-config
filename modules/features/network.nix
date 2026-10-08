{
  flake.modules.nixos.network = {
    networking = {
      networkmanager.enable = true;
      modemmanager.enable = false;
    };
  };
}
