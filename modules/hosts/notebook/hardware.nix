{
  den.aspects.notebook.nixos =
    { pkgs, ... }:
    {
      boot = {
        initrd.availableKernelModules = [
          "nvme"
          "thunderbolt"
          "xhci_pci"
          "usbhid"
        ];
        kernelModules = [ "kvm-intel" ];
      };

      hardware = {
        cpu.intel.updateMicrocode = true;
        graphics.extraPackages = [ pkgs.intel-media-driver ];
      };

      environment.variables.LIBVA_DRIVER_NAME = "iHD";
    };
}
