{ ... }:

{
  nixosModule = {
    # Install Virtualbox
    virtualisation.virtualbox.host = {
      enable = true;
    };

    # Add User to Virtualbox Group to Allow Usage
    users.users.sean.extraGroups = [ "vboxusers" ];
  };

  homeManagerModule = { };
}
