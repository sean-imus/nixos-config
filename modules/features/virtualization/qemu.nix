{ ... }:
{
  # Per-user opt-in to libvirt access. The host enables the service (below); a user
  # who imports this HM aspect requests the libvirtd group. The user-groups bridge
  # grants it only on hosts where qemu created the group (notebook, not vm).
  flake.modules.homeManager.qemu = {
    userCfg.extraGroups = [ "libvirtd" ];
  };

  flake.modules.nixos.qemu =
    { pkgs, ... }:
    {
      virtualisation.libvirtd = {
        enable = true;
        qemu = {
          swtpm.enable = true;
        };
      };

      preservation.preserveAt."/persist".directories = [
        "/var/lib/libvirt/"
      ];

      programs.virt-manager = {
        enable = true;
      };

      systemd.services.libvirtd.postStart = ''
        ${pkgs.libvirt}/bin/virsh net-info default >/dev/null 2>&1 || \
        ${pkgs.libvirt}/bin/virsh net-define ${pkgs.libvirt}/var/lib/libvirt/qemu/networks/default.xml 2>/dev/null || true
        ${pkgs.libvirt}/bin/virsh net-start default 2>/dev/null || true
        ${pkgs.libvirt}/bin/virsh net-autostart default 2>/dev/null || true
      '';
    };
}
