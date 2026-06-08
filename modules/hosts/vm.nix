{ inputs, ... }:
{
  flake.modules.nixos.vm =
    { ... }:
    {
      imports = with inputs.self.modules.nixos; [
        hostDefault
        disko
        persistence
        sean-desktop
      ];

      home-manager.users.sean.programs.niri.settings.input.mod-key = "Alt";

      home-manager.users.sean.programs.niri.settings.outputs."Virtual-1" = {
        mode = {
          width = 1920;
          height = 1080;
          refresh = 60.0;
        };
        position = {
          x = 0;
          y = 0;
        };
      };

      diskoConfigDevice = "/dev/disk/by-id/virtio-ROOT";
      diskoSwapSize = "10G";

      networking.hostName = "vm";

      boot.initrd.availableKernelModules = [
        "virtio_blk"
        "virtio_pci"
      ];
    };

  flake.nixosConfigurations = inputs.self.lib.mkNixos "x86_64-linux" "vm";
}
