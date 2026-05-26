{ inputs, ... }:
{
  flake.modules.nixos.vm =
    { ... }:
    {
      imports = with inputs.self.modules.nixos; [
        vm-system
        disko
        persistence
        sean
      ];

      hostCfg.user.sean.desktop = true;

      home-manager.users.sean.programs.niri.settings.input.mod-key = "Alt";

      diskoConfigDevice = "/dev/disk/by-id/virtio-ROOT";

      networking.hostName = "vm";

      boot.initrd.availableKernelModules = [
        "virtio_blk"
        "virtio_pci"
      ];
    };
}
