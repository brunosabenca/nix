{ pkgs, ... }:
{
  # Default system packages
  environment.systemPackages = with pkgs; [
    home-manager # manage my home dir/programs
    cowsay # very important
    fastfetch # very important
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
    parted # manage disk partitions
    gptfdisk # manage disk partitions
    kalker # cmdline calculator
    just # simple cmd runner
    asciiquarium # very important
    lshw # Detailed info on connected hardware
    busybox # unix utilities
    toybox # unix utilities
    usbutils # lsusb
    pciutils # inspecting and manipulating configuration of PCI devices
    cachix # nix binary cache cli
    nix-ld # Run unpatched dynamic binaries on NixOS
    zenith # htop replacement
    chafa # show images in terminal
    zip # zip stuff
    unzip # unzip stuff
    yt-dlp # youtube-dl fork
    dig # DNS lookup
    nethogs # network monitor tool
    imagemagick # a classic
    poppler-utils # pdfunite and other pdf utils
    pandoc # classic haskell lib for file type conversions
    ffmpeg-headless # its ffmpeg, without pulling in SDL/GTK/mesa via ffplay

    curl
    gnumake
    lazygit
    nixfmt
    nixfmt-tree
    p7zip-rar
    atool
  ];
}
