{ pkgs, ... }:

{
  # Install Virtualbox
  virtualisation.virtualbox.host = {
    enable = true;
  };

  # Add users to virtualbox group to allow usage
  users.users.sean.extraGroups = [ "vboxusers" ];
}
