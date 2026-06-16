{ ... }:
{
  flake.modules.nixos.fingerprint =
    { pkgs, ... }:
    {
      services.fprintd = {
        enable = true;
        package = pkgs.fprintd-tod.overrideAttrs (old: {
          postPatch = (old.postPatch or "") + ''
            substituteInPlace pam/pam_fprintd.c \
              --replace-fail '#define MIN_TIMEOUT 10' '#define MIN_TIMEOUT 1'
          '';
        });
        tod = {
          enable = true;
          driver = pkgs.libfprint-2-tod1-elan;
        };
      };

      security.pam.services.sudo.rules.auth.fprintd.settings.timeout = 3;

      security.pam.services.hyprlock.fprintAuth = false;

      home-manager.users.sean.programs.hyprlock.settings.auth.fingerprint = {
        enabled = true;
        ready_message = "Scan fingerprint to unlock";
        present_message = "Scanning...";
        retry_delay = 250;
      };

      preservation.preserveAt."/persist".directories = [ "/var/lib/fprint" ];
    };
}
