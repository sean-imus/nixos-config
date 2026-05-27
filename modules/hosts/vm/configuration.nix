{ inputs, ... }:
{
  flake.modules.nixos.vm =
    { lib, ... }:
    {
      imports = with inputs.self.modules.nixos; [
        hostDefault
        niri
        disko
        persistence
        sean
      ];

      hostCfg = {
        user.sean.desktop = true;
      };

      home-manager.users.sean.programs.niri.settings.input.mod-key = "Alt";

      diskoConfigDevice = "/dev/disk/by-id/virtio-ROOT";
      diskoSwapSize = "10G";

      networking.hostName = "vm";

      boot.initrd.availableKernelModules = [
        "virtio_blk"
        "virtio_pci"
      ];
    };
}
