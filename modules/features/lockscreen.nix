{ ... }:
{
  security.pam.services.swaylock = { };

  home-manager.users.sean.imports = [
    (
      { ... }:
      {
        programs.swaylock = {
          enable = true;
          settings = {
            color = "000000";
          };
        };
      }
    )
  ];
}
