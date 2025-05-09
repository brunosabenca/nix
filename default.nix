{
  inputs,
  home-manager,
  config,
  pkgs,
  ...
}: {
  imports = [
    home-manager.nixosModules.home-manager
    ./hosts
    ./modules
  ];

  stylix = {
    enable = true;
    image = config.lib.stylix.pixel "base0A";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
  };

  services.actual.enable = true;

  home-manager = {
    users = {
      bruno = import ./home.nix;
    };
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    extraSpecialArgs = {inherit inputs;};
  };

  nix.settings.experimental-features = ["nix-command" "flakes"];

  programs.zsh.enable = true;
  users.users.bruno = {
    shell = pkgs.zsh;
  };

  virtualisation.docker.enable = true;
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  # Set your time zone.
  time.timeZone = "Europe/London";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  services = {
    xserver = {
      desktopManager.gnome.enable = true;
      displayManager = {
        gdm.enable = true;
      };
      enable = true;
      xkb = {
        layout = "us";
        variant = "";
      };
    };

    printing.enable = false;
    pulseaudio.enable = false;
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.bruno = {
    isNormalUser = true;
    description = "Bruno";
    extraGroups = ["networkmanager" "wheel"];
  };

  nix.settings.trusted-users = ["root" "@wheel"];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    home-manager # manage my home dir/programs
    cowsay
    neofetch
    eza
    duf
    jq
    git
    wget
    bat
    ripgrep
    fd
    findutils
    tree
    glow
    coreutils
    killall
    bitwarden-cli
    asciiquarium
    lshw
    usbutils
    pciutils
    cachix
    nix-ld
    appimage-run
    zip
    unzip
    colemak-dh
    ffmpeg
    imagemagick
    nethogs
    kdePackages.kcalc
    neocmakelsp
    clang-tools
    clang_17
    gnumake
    wget
    curl
    rofi-wayland
    waybar
    mako
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
    gnome-tweaks
    gnomeExtensions.unite
  ];

  # Enable nix-ld to use dynamically linked executables with hardcoded paths
  programs.nix-ld = {
    enable = true;
    package = pkgs.nix-ld-rs;
  };

  # Enable envfs for fhs compatibility
  services.envfs.enable = true;

  environment.sessionVariables = {
    EDITOR = "nvim";
    # If your cursor becomes invisible
    WLR_NO_HARDWARE_CURSORS = "1";
    # Hint electron aps to use wayland
    NIXOS_OZONE_WL = "1";
  };

  environment.shellAliases = {
    ll = "ls -l";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  programs.htop = {
    enable = true;
    settings.show_cpu_temperature = 1;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  networking.firewall.allowedTCPPorts = [
    50341
  ];
  networking.firewall.allowedUDPPorts = [
    50341
  ];

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  fonts = {
    enableDefaultPackages = true;
    fontconfig = {
      antialias = true;
      hinting.enable = true;
      hinting.autohint = true;
    };
  };

  hardware.graphics.enable = true;

  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-archive-plugin
      thunar-volman
    ];
  };

  programs.partition-manager.enable = true;
  services.gvfs.enable = true; # Mount, trash, and other functionalities
  services.tumbler.enable = true; # Thumbnail support for images
  security.polkit.enable = true;
}
