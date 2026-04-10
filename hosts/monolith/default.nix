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

  services.udev = {

    packages = with pkgs; [
      qmk
      qmk-udev-rules
      qmk_hid
      via
      vial
    ]; # packages

  }; # udev

  services.tailscale.enable = true;

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

  boot.supportedFilesystems = [
    "ntfs"
    "fuse.sshfs"
  ];

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
      capSysNice = true;
    };
    steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
      gamescopeSession.enable = true;
    };
    gamemode = {
      enable = true;
    };
    corectrl = {
      enable = false;
    };
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
