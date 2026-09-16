{ pkgs, ... }:
let
  dockAutoswitch = pkgs.writeShellApplication {
    name = "niri-dock-autoswitch";
    runtimeInputs = [
      pkgs.jq
      pkgs.niri
      pkgs.procps
    ];
    text = ''
      stop_rdp() {
        pkill -TERM -x sdl-freerdp || true
        for _ in {1..10}; do
          pgrep -x sdl-freerdp >/dev/null 2>&1 || break
          sleep 0.1
        done
        pkill -KILL -x sdl-freerdp || true
      }

      apply() {
        local outputs
        outputs=$(niri msg --json outputs 2>/dev/null) || return 0
        jq -e 'type == "object"' <<<"$outputs" >/dev/null 2>&1 || return 0

        local iiyamas edp_on
        iiyamas=$(jq '[.[] | select(.make == "iiyama Corporation" and .model == "PL2770H" and .logical != null)] | length' <<<"$outputs") || return 0

        if jq -e '.["eDP-1"].logical != null' <<<"$outputs" >/dev/null 2>&1; then
          edp_on=true
        else
          edp_on=false
        fi

        if ((iiyamas > 0)); then
          if [[ $edp_on == true ]]; then
            niri msg output eDP-1 off || true
          fi
        elif [[ $edp_on == false ]]; then
          stop_rdp
          niri msg output eDP-1 on || true
        fi
      }

      while true; do
        apply || true
        sleep 2
      done
    '';
  };
in
{
  wayland.windowManager.niri.settings._children = [
    {
      output = {
        _args = [ "eDP-1" ];
        position._props = {
          x = 0;
          y = 0;
        };
      };
    }
    {
      output = {
        _args = [ "iiyama Corporation PL2770H 0x0000011F" ];
        mode._args = [ "1920x1080" ];
        position._props = {
          x = -1920;
          y = 0;
        };
      };
    }
    {
      output = {
        _args = [ "iiyama Corporation PL2770H 0x00000124" ];
        mode._args = [ "1920x1080" ];
        position._props = {
          x = -3840;
          y = 0;
        };
        "focus-at-startup" = { };
      };
    }
  ];

  systemd.user.services.niri-dock-autoswitch = {
    Unit = {
      Description = "Keep the internal panel off while docked and stop RDP when the dock is removed";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
      ConditionEnvironment = "WAYLAND_DISPLAY";
    };
    Service = {
      ExecStart = "${dockAutoswitch}/bin/niri-dock-autoswitch";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
