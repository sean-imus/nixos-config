{
  den.aspects.virtualisation = {
    nixos = {
      virtualisation = {
        libvirtd = {
          enable = true;
          qemu.swtpm.enable = true;
        };
        spiceUSBRedirection.enable = true;
      };

      systemd.tmpfiles.settings.libvirt-default-network."/var/lib/libvirt/qemu/networks/autostart/default.xml".L =
        {
          argument = "/var/lib/libvirt/qemu/networks/default.xml";
        };

      programs.virt-manager.enable = true;
    };

    user.extraGroups = [ "libvirtd" ];

    homeManager.dconf.settings."org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
  };
}
