{ ... }:

{
  xdg.desktopEntries.rdp-to-work = {
    name = "Connect to Work Laptop";
    exec = "xfreerdp /v:192.168.200.1 /u:stietz /p: /d:ENTEX /f /dynamic-resolution /kbd:layout:0x0407,lang:0x0407";
    terminal = false;
  };
}
