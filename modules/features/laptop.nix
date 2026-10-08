{
  flake.modules.nixos.laptop = {
    services = {
      power-profiles-daemon.enable = true;

      logind.settings.Login = {
        HandleLidSwitch = "lock";
        HandleLidSwitchExternalPower = "lock";
        HandleLidSwitchDocked = "ignore";
      };

      upower = {
        enable = true;
        usePercentageForPolicy = true;
        percentageLow = 20;
        percentageCritical = 10;
        percentageAction = 5;
        criticalPowerAction = "Hibernate";
      };
    };
  };
}
