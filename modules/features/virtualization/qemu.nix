{ ... }:
{
  # Notebook-only named aspect (the VM doesn't nest virt). Importing it gives the
  # host libvirtd AND joins every one of its users to the libvirtd group — the
  # group request rides sharedModules so no user is named here, and the
  # user-groups bridge drops it on hosts where the group is absent.
  flake.modules.nixos.qemu =
    { pkgs, ... }:
    {
      home-manager.sharedModules = [ { userCfg.extraGroups = [ "libvirtd" ]; } ];

      virtualisation.libvirtd = {
        enable = true;
        qemu.swtpm.enable = true;
      };

      # VM definitions/disks/networks live here — persisted by this module so the
      # path only exists on hosts that actually run libvirt.
      preservation.preserveAt."/persist".directories = [
        "/var/lib/libvirt/"
      ];

      programs.virt-manager.enable = true;

      # libvirt ships a `default` NAT network but doesn't define/start it on a
      # fresh (impermanent) boot — recreate it idempotently each start.
      systemd.services.libvirtd.postStart = ''
        ${pkgs.libvirt}/bin/virsh net-info default >/dev/null 2>&1 || \
        ${pkgs.libvirt}/bin/virsh net-define ${pkgs.libvirt}/var/lib/libvirt/qemu/networks/default.xml 2>/dev/null || true
        ${pkgs.libvirt}/bin/virsh net-start default 2>/dev/null || true
        ${pkgs.libvirt}/bin/virsh net-autostart default 2>/dev/null || true
      '';
    };
}
