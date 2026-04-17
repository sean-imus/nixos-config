{ pkgs, ... }:

{
  # Install remmina
  services.remmina.enable = true;

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
