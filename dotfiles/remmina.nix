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
    password=
    viewmode=4
    scale=2
  '';
  xdg.dataFile."remmina/work-notebook.remmina".force = true;

  # Shell alias to bring up static IP for work notebook rdp connection
  home.shellAliases = {
    rdpup = "nmcli con up rdp-static-eth";
  };
}
