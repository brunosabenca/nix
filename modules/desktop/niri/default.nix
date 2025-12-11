{
  pkgs,
  username,
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
      programs.alacritty.enable = true; # Super+T in the default setting (terminal)
      programs.fuzzel.enable = true; # Super+D in the default setting (app launcher)
      programs.swaylock.enable = true; # Super+Alt+L in the default setting (screen locker)
      programs.waybar.enable = true; # launch on startup in the default setting (bar)

      services.mako.enable = true; # notification daemon
      services.swayidle.enable = true; # idle management daemon
      services.polkit-gnome.enable = true; # polkit

      home.packages = with pkgs; [
        swaybg # wallpaper
      ];
    };
}
