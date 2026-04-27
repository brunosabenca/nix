{
  pkgs,
  username,
  lib,
  ...
}:
{
  imports = [ ../common ];

  environment.systemPackages = with pkgs; [
    wev # wayland event viewer (find out key names)
    notify-desktop # provides the notify-send binary to trigger mako
    libinput # Handles input devices in Wayland compositors
    libinput-gestures # Gesture mapper for libinput
    networkmanager # Manage wireless networks
    pulsemixer # CLI to control puleaudio
    alsa-utils # for amixer to mute mic
    wdisplays # xrandr type gui to mess with monitor placement
    wl-mirror # simple wayland display mirror program
    nautilus
    xwayland-satellite # xwayland support
  ];

  programs.niri.enable = true;

  services.upower.enable = true;

  programs.dms-shell = {
    enable = true;
    systemd = {
      restartIfChanged = true;
    };
  };

  services.displayManager = {
    dms-greeter = {
      enable = true;
      compositor.name = "niri";
    };
  };

  home-manager.users.${username} =
    {
      pkgs,
      ...
    }:
    {
      programs.fuzzel = {
        enable = true;
        settings = {
          main = {
            font = lib.mkForce "JetBrains Mono:size=23";
            horizontal-pad = 20;
            lines = 8;
            exit-on-keyboard-focus-loss = true;
            terminal = "kitty";
          };
          border = {
            width = 4;
            radius = 8;
          };
          colours = {
            background = "1e1e2ef7";
            text = "cdd6f4ff";
            match = "cba6f7ff";
            selection = "585b70ff";
            selection-text = "cdd6f4ff";
            selection-match = "cba6f7ff";
            border = "cba6f7ff";
          };
        };
      };

      xdg.configFile."niri/config.kdl".source = ./config.kdl;
    };
}
