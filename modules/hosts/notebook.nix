{ inputs, ... }:
{
  flake.modules.nixos.notebook =
    { config, ... }:
    {
      imports = with inputs.self.modules.nixos; [
        hostDefault
        disko
        impermanence
        qemu
        sean
      ];

      hostCfg = {
        hm.enable = true;
        audio.enable = true;
        niri.enable = true;
        printing.enable = true;
        rdp-work.enable = true;
      };
      userCfg = {
        terminal.enable = true;
        browser.enable = true;
        btop.enable = true;
        fastfetch.enable = true;
        git.enable = true;
        shell.enable = true;
        sops.enable = true;
        ssh.enable = true;
        niri.enable = true;
        bar.enable = true;
        lockscreen.enable = true;
        vesktop.enable = true;
        opencode.enable = true;
        localsend.enable = true;
        libreoffice.enable = true;
        printing.enable = true;
        rdp-work.enable = true;
        nixvim.enable = true;
      };

      diskoConfigDevice = "/dev/disk/by-id/nvme-SAMSUNG_MZALQ512HALU-000L2_S4UKNF0R457642";

      networking.hostName = "notebook";

      hardware = {
        enableRedistributableFirmware = true;
        cpu.intel.updateMicrocode = true;
        bluetooth.enable = true;
      };

      boot.initrd.availableKernelModules = [
        "nvme"
        "thunderbolt"
        "xhci_pci"
        "usbhid"
      ];

      boot.kernelModules = [
        "kvm-intel"
        "i915"
      ];

      services.power-profiles-daemon.enable = true;

      environment.shellAliases = {
        rbs = "sudo nixos-rebuild switch --flake .#${config.networking.hostName}";
        rbb = "sudo nixos-rebuild boot --flake .#${config.networking.hostName} && reboot";
      };
    };
}
