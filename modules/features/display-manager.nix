{ pkgs, ... }:
{
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --issue --remember --cmd Hyprland";
        user = "greeter";
      };
    };
  };
}
