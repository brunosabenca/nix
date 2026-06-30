{
  config,
  lib,
  pkgs,
  home-manager,
  username,
  modulesPath,
  inputs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  nixpkgs.overlays = [
    (final: prev: {
      openldap = prev.openldap.overrideAttrs (_: { doCheck = false; });
    })
  ];

  home-manager.users.${username} =
    {
      pkgs,
      ...
    }:
    {
      home.packages = with pkgs; [
        bottles
        vial
      ];

      services.easyeffects.enable = true;
    };

  # plugdev is a Debian convention referenced in qmk-udev-rules; uaccess handles
  # actual device access, but the group must exist to silence the udevd warning.
  users.groups.plugdev = { };
  users.users.${username}.extraGroups = lib.mkAfter [ "plugdev" ];

  services.udev = {
    extraRules = ''
      ACTION=="add|change", KERNEL=="nvme[0-9]*n[0-9]*", ENV{DEVTYPE}=="disk", ATTR{queue/scheduler}="bfq"
    '';

    packages = with pkgs; [
      qmk
      qmk-udev-rules
      qmk_hid
      via
      vial
    ]; # packages

  }; # udev

  services.tailscale.enable = true;

  services.sunshine = {
    enable = true;
    openFirewall = true;
    capSysAdmin = true;
  };

  networking = {
    hostName = "monolith";
    networkmanager.enable = true;
    firewall.allowedTCPPortRanges = [
      {
        from = 9090;
        to = 9090;
      }
      {
        from = 24800;
        to = 24800;
      }
    ];
    firewall.allowedUDPPortRanges = [
      {
        from = 9090;
        to = 9090;
      }
      {
        from = 24800;
        to = 24800;
      }
    ];
  };

  services.syncthing = {
    enable = true;
    group = "users";
    user = "bruno";
    dataDir = "/home/bruno/Sync"; # Default folder for new synced folders
    configDir = "/home/bruno/.config/syncthing"; # Folder for Syncthing's settings and keys
  };

  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.systemd-boot.memtest86.enable = true;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };

  boot.kernel.sysctl = {
    "vm.dirty_background_bytes" = 134217728; # 128MB - start background writeback
    "vm.dirty_bytes" = 268435456;            # 256MB - throttle processes
  };

  boot.supportedFilesystems = [
    "ntfs"
    "fuse.sshfs"
  ];

  boot.extraModprobeConfig = ''
    options uvcvideo quirks=0x20
  '';

  hardware.graphics = {
    enable = true;
  };

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  environment.systemPackages = with pkgs; [
    distrobox
    spotify
    lmstudio
  ];

  zramSwap = {
    enable = true;
    memoryPercent = 50;
    algorithm = "zstd";
  };

  services.earlyoom = {
    enable = true;
    freeMemThreshold = 5;
    freeSwapThreshold = 5;
    enableNotifications = true;
  };

  services.xserver.dpi = 108;
  services.xserver.videoDrivers = [ "amdgpu" ];

  # Needed for corectrl
  hardware.amdgpu.overdrive.enable = true;

  programs = {
    gamescope = {
      enable = true;
      # disabled: ambient cap_sys_nice propagates to bwrap, which Steam's
      # runtime sandbox uses and refuses to start with inherited caps
      capSysNice = false;
    };
    steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
    };
    gamemode = {
      enable = true;
    };
    corectrl = {
      enable = false;
    };
  };

  jovian.steam = {
    enable = true;
  };

  # steamos-manager checks for this file before registering the SessionManagement1
  # D-Bus interface (com.steampowered.SteamOSManager1.SessionManagement1), which is
  # what Steam/gamescope calls when the user clicks "Return to Desktop".
  environment.etc."sddm.conf.d/holo.conf".text = "";

  # Tell steamos-manager that niri is our desktop session, so SwitchToDesktopMode
  # terminates gamescope-session.target and returns to greetd.
  systemd.user.services.jovian-setup-desktop-session = {
    wants = [ "steamos-manager.service" ];
    after = [ "steamos-manager.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.steamos-manager}/bin/steamosctl set-default-desktop-session niri.desktop";
    };
    wantedBy = [ "graphical-session.target" ];
  };

  services.samba = {
    enable = true;
    openFirewall = true;

    # You will still need to set up the user accounts to begin with:
    # $ sudo smbpasswd -a yourusername

    settings = {
      global = {
        browseable = "yes";
        "smb encrypt" = "required";
      };
      homes = {
        browseable = "no"; # note: each home will be browseable; the "homes" share will not.
        "read only" = "no";
        "guest ok" = "no";
      };
    };
  };
}
