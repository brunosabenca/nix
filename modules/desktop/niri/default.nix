{
  pkgs,
  username,
  lib,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    wev # wayland event viewer (find out key names)
    notify-desktop # provides the notify-send binary to trigger mako
    wl-clipboard-rs # wl-copy and wl-paste for copy/paste from stdin / stdout
    libinput # Handles input devices in Wayland compositors
    libinput-gestures # Gesture mapper for libinput
    brightnessctl # CLI to control brightness
    networkmanager # Manage wireless networks
    pulsemixer # CLI to control puleaudio
    alsa-utils # for amixer to mute mic
    wdisplays # xrandr type gui to mess with monitor placement
    wl-mirror # simple wayland display mirror program
    nautilus
    xwayland-satellite # xwayland support
  ];

  programs.niri.enable = true;

  home-manager.users.${username} =
    {
      config,
      pkgs,
      ...
    }:
    {
      programs.alacritty.enable = true;
      programs.fuzzel = {
        enable = true;
        settings = {
          main = {
            font = lib.mkForce "JetBrains Mono:size=23";
            horizontal-pad = 20;
            lines = 8;
            exit-on-keyboard-focus-loss = true;
            terminal = "alacritty -e";
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
      programs.swaylock.enable = true;
      programs.waybar.enable = true;

      services.mako.enable = true;
      services.swayidle.enable = true;
      services.polkit-gnome.enable = true;

      home.packages = with pkgs; [
        swaybg
      ];
    };
}
