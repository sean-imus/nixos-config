{ ... }:
{
  flake.modules.nixos.fingerprint =
    { pkgs, ... }:
    {
      services.fprintd = {
        enable = true;
        # pam_fprintd.c in fprintd-tod 1.90.9 clamps any timeout below 10s to 10s.
        # Patch the constant out so our timeout=3 for sudo is actually respected.
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

      # hyprlock's native auth.fingerprint talks to fprintd directly and runs
      # in parallel with the password field — no PAM blocking involved.
      # Disable fprintAuth so pam_fprintd doesn't also block the password path.
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
