{ den, ... }:
{
  den.hosts.x86_64-linux.notebook.users.sean = { };

  den.aspects.notebook = {
    includes = with den.aspects; [
      base
      desktop
      hardware-dev
      logitech
      power
      printing
      rdp-work
      virtualisation
    ];

    nixos = {
      services.getty = {
        autologinUser = "sean";
        autologinOnce = true;
      };

      system.stateVersion = "26.11";
    };
  };
}
