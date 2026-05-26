{ inputs, ... }:
{
  flake.modules.nixos.gaming-notebook =
    { config, ... }:
    {
      imports = with inputs.self.modules.nixos; [
        hostDefault
        disko
        impermanence
        sean
      ];

      hostCfg = {
        hm.enable = true;
        audio.enable = true;
        niri.enable = true;
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
        nixvim.enable = true;
      };

      diskoConfigDevice = "/dev/disk/by-id/nvme-FIXME-ME";

      networking.hostName = "gaming-notebook";

      nixpkgs.config.allowUnfree = true; # NOTE Sadly the open-source drivers are borderline unusable, even the iGPU would provide compareable performance. So we have to use the closed-source drivers.

      hardware = {
        enableRedistributableFirmware = true;
        cpu.intel.updateMicrocode = true;
        bluetooth.enable = true;
        graphics.enable = true;
        nvidia = {
          modesetting.enable = true;
          nvidiaSettings = true;
          open = false;
        };
      };

      boot.initrd.availableKernelModules = [
        "nvme"
        "xhci_pci"
        "usbhid"
      ];

      boot.kernelModules = [
        "kvm-intel"
        "i915"
        "nvidia"
        "nvidia_drm"
        "nvidia_modeset"
        "nvidia_uvm"
      ];

      environment.shellAliases = {
        rbs = "sudo nixos-rebuild switch --flake .#${config.networking.hostName}";
        rbb = "sudo nixos-rebuild boot --flake .#${config.networking.hostName} && reboot";
      };
    };
}
