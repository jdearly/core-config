{
  lib,
  pkgs,
  ...
}: let
  mod = "Mod1";
in {
  programs.swayr = {
    enable = true;
    systemd.enable = true;
  };

  programs.swayimg.enable = true;

  wayland.windowManager.sway = {
    enable = true;
    config = {
      modifier = mod;
      terminal = "ghostty";
      keybindings = lib.mkOptionDefault {
        "${mod}+Ctrl+l" = "exec ${pkgs.swaylock-fancy}/bin/swaylock-fancy";
      };
      window.titlebar = false;
      floating.titlebar = false;
      input = {
        "type:keyboard" = {
          repeat_rate = "40";
          repeat_delay = "200";
        };
      };
      # output = {
      #   "HDMI-A-1" = {
      #     mode = "2560x1440@144.0Hz";
      #   };
      #   "DP-3" = {
      #     mode = "2560x1440@144.0Hz";
      #   };
      # };
    };
  };

  programs.waybar = {
    style = ''
      * {
          border: none;
          border-radius: 0;
          font-family: Roboto, Helvetica, Arial, sans-serif;
          font-size: 13px;
          min-height: 0;
      }

      window#waybar {
          background: rgba(43, 48, 59, 0.5);
          border-bottom: 3px solid rgba(100, 114, 125, 0.5);
          color: white;
      }

      tooltip {
        background: rgba(43, 48, 59, 0.5);
        border: 1px solid rgba(100, 114, 125, 0.5);
      }
      tooltip label {
        color: white;
      }

      #workspaces button {
          padding: 0 5px;
          background: transparent;
          color: white;
          border-bottom: 3px solid transparent;
      }

      #workspaces button.focused {
          background: #64727D;
          border-bottom: 3px solid white;
      }

      #mode, #clock, #battery {
          padding: 0 10px;
      }

      #mode {
          background: #64727D;
          border-bottom: 3px solid white;
      }

      #clock {
          background-color: #64727D;
      }

      #battery {
          background-color: #ffffff;
          color: black;
      }

      #battery.charging {
          color: white;
          background-color: #26A65B;
      }

      @keyframes blink {
          to {
              background-color: #ffffff;
              color: black;
          }
      }

      #battery.warning:not(.charging) {
          background: #f53c3c;
          color: white;
          animation-name: blink;
          animation-duration: 0.5s;
          animation-timing-function: steps(12);
          animation-iteration-count: infinite;
          animation-direction: alternate;
      }
    '';
    enable = true;
    settings = {};
    systemd.enable = true;
  };

  services.swayidle = {
    enable = true;
  };
}
