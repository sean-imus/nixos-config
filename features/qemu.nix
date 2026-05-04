{ ... }:

{
  nixosModule = {
    virtualisation.libvirtd = {
      enable = true;
    };

    programs.virt-manager = {
      enable = true;
    };

    users.users.sean.extraGroups = [ "libvirtd" ];
  };

  homeManagerModule = { };
}
