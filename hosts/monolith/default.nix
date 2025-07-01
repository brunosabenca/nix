{
  config,
  lib,
  pkgs,
  modulesPath,
  inputs,
  ...
}:{
  imports = [
    ./hardware-configuration.nix
  ];

  networking = {
    hostName = "monolith";
    networkmanager.enable = true;
    firewall.allowedTCPPortRanges = [
      {
        from = 9090;
        to = 9090;
      }
    ];
    firewall.allowedUDPPortRanges = [
      {
        from = 9090;
        to = 9090;
      }
    ];
  };

  services.actual.enable = true;

  fileSystems."/mnt/cave" = {
    device = "bruno@192.168.0.14:/mnt/data";
    fsType = "fuse.sshfs";
    options = [
      "identityfile=/home/bruno/.ssh/id_ed25519"
      "idmap=user"
      "x-systemd.automount" #< mount the filesystem automatically on first access
      "allow_other" #< don't restrict access to only the user which `mount`s it (because that's probably systemd who mounts it, not you)
      "user" #< allow manual `mount`ing, as ordinary user.
      "rw"
      "_netdev"
    ];
  };

  boot.supportedFilesystems = [
    "ntfs"
    "fuse.sshfs"
  ];

  hardware.graphics = {
    enable = true;

    extraPackages = with pkgs; [
      amdvlk
    ];
  };


  # Force radv
  environment.variables.AMD_VULKAN_ICD = "RADV";
  services.xserver.dpi = 108;
  services.xserver.videoDrivers = ["amdgpu"];

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
      enable = true;
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
