{
  inputs,
  pkgs,
  lib,
  config,
  username,
  ...
}: {
  # enable OpenGL
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  services.desktopManager.plasma6.enable = true;

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  # Set plasma6 as default session
  services.displayManager.defaultSession = "plasma";

  # KDE system packages
  environment.systemPackages = with pkgs; [
    kdePackages.kcalc
    kdePackages.kleopatra
    kdePackages.spectacle
    kdePackages.gwenview
    kdePackages.dolphin
    kdePackages.okular
    kdePackages.qtstyleplugin-kvantum
    libnotify
    xclip
    wl-clipboard-rs
  ];

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    # konsole
  ];

  programs.kdeconnect.enable = true;
  environment.sessionVariables = {
    QT_QPA_PLATFORM = "wayland";
  };

  networking.firewall = {
    enable = true;
    allowedTCPPortRanges = [
      {
        from = 1714;
        to = 1764;
      } # KDE Connect
    ];
    allowedUDPPortRanges = [
      {
        from = 1714;
        to = 1764;
      } # KDE Connect
    ];
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  home-manager.users.${username} = {
    stylix.targets.kde.enable = false;
  };
}
