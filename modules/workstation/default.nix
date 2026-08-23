{ pkgs, ... }:
{
  imports = [
    ../core/mpv
    ../core/audio
  ];

  environment.systemPackages = with pkgs; [
    brightnessctl # CLI for brightness
    playerctl # CLI to control media players
    gparted # manage disk partitions (GUI; parted/gptfdisk cover the CLI case)
    appimage-run # Setup common unix libs required to run appimages on nixos
    inkscape # wish I was smart enough for this
    qimgv # image viewer
    picard # GUI to edit music metadata
    zenity # spawn xdg portals
    qdirstat # see whats taking space on filesystem
    kdePackages.kcalc # KDE calculator
    neovide
    wl-clipboard-rs
    colemak-dh
    libnotify
    kdePackages.polkit-kde-agent-1
    pavucontrol
    wezterm
    kitty
    sniffnet # network monitor tool (GUI)
    kcc
  ];

  hardware.bluetooth = {
    enable = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
        AutoEnable = true;
        ControllerMode = "dual";
      };
      General.UserspaceHID = true;
    };
    powerOnBoot = true;
  };

  fonts = {
    enableDefaultPackages = true;
    fontconfig = {
      antialias = true;
      hinting = {
        enable = true;
        autohint = true;
      };
      subpixel.rgba = "rgb";
    };
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
    ];
  };

  programs.partition-manager.enable = true;
  services.gvfs.enable = true; # Mount, trash, and other functionalities
  services.tumbler.enable = true; # Thumbnail support for images
}
