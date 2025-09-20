{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./audio-configuration.nix
  ];

  networking = {
    hostName = "cave";
    networkmanager.enable = true;

    firewall.allowedTCPPortRanges = [
      {
        from = 38844;
        to = 38844;
      }
      {
        from = 22;
        to = 22;
      }
    ];
    firewall.allowedUDPPortRanges = [
      {
        from = 38844;
        to = 38844;
      }
    ];
  };

  powerManagement.cpuFreqGovernor = "performance";

  hardware.sensor.iio.enable = true;

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
    ];
  };

  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
    AllowHybridSleep=no
    AllowSuspendThenHibernate=no
  '';

  services = {
    getty.autologinUser = "bruno";

    logind = {
      lidSwitch = "ignore";
      extraConfig = ''
        HandlePowerKey=ignore
      '';
    };

    acpid = {
      enable = true;
      lidEventCommands = ''
        export PATH=$PATH:/run/current-system/sw/bin

        lid_state=$(cat /proc/acpi/button/lid/LID0/state | awk '{print $NF}')
        if [ $lid_state = "closed" ]; then
          # Set brightness to zero
          echo 0  > /sys/class/backlight/intel_backlight/brightness
        else
          # Reset the brightness
          echo 50  > /sys/class/backlight/intel_backlight/brightness
        fi
      '';

      powerEventCommands = ''
        systemctl suspend
      '';
    };

    openssh = {
      enable = true;
      ports = [ 22 ];
      settings = {
        PasswordAuthentication = true;
        AllowUsers = null; # Allows all users by default. Can be [ "user1" "user2" ]
        UseDns = true;
        X11Forwarding = false;
        PermitRootLogin = "prohibit-password"; # "yes", "without-password", "prohibit-password", "forced-commands-only", "no"
      };

      keyd = {
        enable = true;
        keyboards = {
          default = {
            ids = [ "*" ];
            extraConfig = ''
              [main]
              f1 = back
              f2 = forward
              f3 = refresh
              f4 = f11
              f5 = scale
              f6 = brightnessdown
              f7 = brightnessup
              f8 = mute
              f9 = volumedown
              f10 = volumeup

              back = back
              forward = forward
              refresh = refresh
              zoom = f11
              scale = scale
              brightnessdown = brightnessdown
              brightnessup = brightnessup
              mute = mute
              volumedown = volumedown
              volumeup = volumeup

              f13=coffee
              sleep=coffee

              [meta]
              f1 = f1
              f2 = f2
              f3 = f3
              f4 = f4
              f5 = f5
              f6 = f6
              f7 = f7
              f8 = f8
              f9 = f9
              f10 = f10

              back = f1
              forward = f2
              refresh = f3
              zoom = f4
              scale = f5
              brightnessdown = f6
              brightnessup = f7
              mute = f8
              volumedown = f9
              volumeup = f10


              [alt]
              backspace = delete
              brightnessdown = kbdillumdown
              brightnessup = kbdillumup
              f6 = kbdillumdown
              f7 = kbdillumup

              [control]
              f5 = sysrq
              scale = sysrq

              [control+alt]
              backspace = C-A-delete

            '';
          };
        };
      };
    };
  };
}
