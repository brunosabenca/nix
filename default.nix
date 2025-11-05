{
  inputs,
  agenix,
  home-manager,
  plasma-manager,
  pkgs,
  username,
  config,
  system,
  ...
}:
{
  imports = [
    # Load agenix and install client package
    agenix.nixosModules.default
    {
      environment.systemPackages = [
        agenix.packages."${system}".default
      ];
    }

    home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "backup";
      home-manager.extraSpecialArgs = { inherit inputs; };
      home-manager.sharedModules = [ plasma-manager.homeModules.plasma-manager ];
    }
    ./hosts
    ./modules
  ];

  # Todo: move below to appropriate modules

  stylix = {
    enable = true;
    image = config.lib.stylix.pixel "base0A";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    fonts = {
      serif.name = "Noto Serif";
      sansSerif.name = "Noto Sans";
      monospace.name = "JetBrains Mono NF";

      sizes = {
        terminal = 12;
        applications = 10;
        popups = 10;
        desktop = 10;
      };
    };
  };

  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;
  home-manager.verbose = true;

  home-manager.users.${username} = import ./home.nix;

  programs.zsh.enable = true;

  virtualisation.docker.enable = false;

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
  users.users.${username} = {
    isNormalUser = true;
    description = "Bruno";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.zsh;
  };

  nix.settings.trusted-users = [
    "root"
    "@wheel"
  ];

  # Enable nix-ld to use dynamically linked executables with hardcoded paths
  programs.nix-ld.enable = true;

  # Enable envfs for fhs compatibility
  services.envfs.enable = true;

  environment.sessionVariables = {
    EDITOR = "nvim";
    # If your cursor becomes invisible
    WLR_NO_HARDWARE_CURSORS = "1";
    # Hint electron aps to use wayland
    NIXOS_OZONE_WL = "1";

    MOZ_USE_XINPUT2 = "1";
  };

  environment.shellAliases = {
    ls = "exa --icons -F -H --group-directories-first --git -1";
    ll = "ls -alF";
    k = "kubectl";
    n = "nvim";
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
  security.polkit.enable = true;
}
