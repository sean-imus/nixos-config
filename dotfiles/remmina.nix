{ pkgs, lib, ... }:

{
  # Install remmina
  services.remmina.enable = true;

  # Create marker file for NixOS to detect remmina presence
  xdg.dataFile."nixos/remmina-active".text = "";

  # Setup Connections
  xdg.dataFile."remmina/work-notebook.remmina".text = ''
    [remmina]
    name=Work Notebook
    server=192.168.200.1
    protocol=RDP
    username=stietz
    domain=ENTEX
  '';
}
