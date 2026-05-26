{ inputs, lib, ... }:
{
  flake.modules.nixos.vm-system = {
    imports = with inputs.self.modules.nixos; [
      hostDefault
      ssh
      niri
    ];

    config = {
      hostCfg = {
        niri.enable = lib.mkDefault true;
      };
    };
  };
}