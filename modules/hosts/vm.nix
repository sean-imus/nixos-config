{ inputs, ... }:
{
  flake.modules.nixos.vm =
    { ... }:
    {
      imports = with inputs.self.modules.nixos; [
        # base + mechanisms (every host)
        hostDefault
        disko
        persistence
        user-groups
        # user + machine capability — full desktop, minus the notebook-only
        # hardware aspects (qemu/tailscale/wifi/power) that are useless in a VM.
        sean
        desktop
      ];

      # Alt as the mod key so it doesn't clash with the host compositor's Super.
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

      diskoCfg = {
        device = "/dev/disk/by-id/virtio-ROOT";
        swapSize = "10G";
        encrypt = false; # no LUKS in the VM — no passphrase prompt at boot
      };

      networking.hostName = "vm";

      boot.initrd.availableKernelModules = [
        "virtio_blk"
        "virtio_pci"
      ];
    };

  flake.nixosConfigurations = inputs.self.lib.mkNixos "x86_64-linux" "vm";
}
