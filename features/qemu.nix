{ pkgs, ... }:

{
  nixosModule = {
    # Install QEMU and libvirtd
    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true; # Emulated TPM Support for VMs
      };
    };

    # Install Management GUI
    programs.virt-manager = {
      enable = true;
    };

    users.users.sean.extraGroups = [ "libvirtd" ];
  };

  # Auto-Start Default Network
  systemd.services.libvirtd.postStart = ''
    ${pkgs.libvirt}/bin/virsh net-info default >/dev/null 2>&1 || \
    ${pkgs.libvirt}/bin/virsh net-define ${pkgs.libvirt}/var/lib/libvirt/qemu/networks/default.xml 2>/dev/null || true
    ${pkgs.libvirt}/bin/virsh net-start default 2>/dev/null || true
    ${pkgs.libvirt}/bin/virsh net-autostart default 2>/dev/null || true
  '';

  homeManagerModule = { };
}
