{ pkgs, ... }:
{
  # Default system packages
  environment.systemPackages = with pkgs; [
    home-manager # manage my home dir/programs
    cowsay # very important
    neofetch # very important
    eza # better ls
    duf # better df (file system tool)
    dysk # another better df
    jq # sed for JSON
    git # its git
    wget # get stuff from the web
    bat # the better cat
    ripgrep # the better grep
    fd # the better find
    findutils # locate etc
    tree # we love green
    glow # md reader
    coreutils # its coreutils
    killall # when you need a shotgun
    brightnessctl # CLI for brightness
    playerctl # CLI to control media players
    gparted # manage disk partitions
    parted # manage disk partitions
    gptfdisk # manage disk partitions
    kalker # cmdline calculator
    just # simple cmd runner
    bitwarden-cli # CLI for bitwarden
    asciiquarium # very important
    lshw # Detailed info on connected hardware
    busybox # unix utilities
    toybox # unix utilities
    usbutils # lsusb
    pciutils # inspecting and manipulating configuration of PCI devices
    cachix # nix binary cache cli
    nix-ld # Run unpatched dynamic binaries on NixOS
    appimage-run # Setup common unix libs required to run appimages on nixos
    zenith # htop replacement
    chafa # show images in terminal
    zip # zip stuff
    unzip # unzip stuff
    yt-dlp # youtube-dl fork
    inkscape # wish I was smart enough for this
    nethogs # network monitor tool
    sniffnet # network monitor tool
    imagemagick # a classic
    poppler-utils # pdfunite and other pdf utils
    pandoc # classic haskell lib for file type conversions
    ffmpeg # its ffmpeg
    telegram-desktop # telegram desktop
    qimgv # image viewer
    picard # GUI to edit music metadata
    zenity # spawn xdg portals
    qdirstat # see whats taking space on filesystem
    kdePackages.kcalc # KDE calculator

    neovide
    wl-clipboard-rs
    colemak-dh
    curl
    neocmakelsp
    gnumake
    libnotify
    kdePackages.polkit-kde-agent-1
    pavucontrol
    # (appimageTools.wrapType1
    #   {
    #     name = "Buckets";
    #     src = fetchurl {
    #       url = "https://github.com/buckets/application/releases/download/v0.75.0/Buckets-linux-latest-amd64-0.75.0.AppImage";
    #       sha256 = "1a3fd50ec57e92cf1b86c170538efea019ac60e6b495030765ea90dff2079bd1";
    #     };
    #   })
    wezterm
    ghostty
    zoxide
    lazygit
    nixfmt
    nixfmt-tree
  ];
}
