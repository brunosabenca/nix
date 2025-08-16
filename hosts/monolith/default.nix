{
  config,
  lib,
  pkgs,
  home-manager,
  username,
  modulesPath,
  inputs,
  ...
}:{
  imports = [
    ./hardware-configuration.nix
  ];

  home-manager.users.${username} = 
    {
      pkgs,
      ...
    }: {
      home.packages = [pkgs.rclone];
      xdg.configFile."rclone/rclone.conf".text = ''
        [cave]
        type = sftp
        host = 192.168.1.30
        user = bruno
        key_file = ${config.users.users.bruno.home}/.ssh/id_ed25519
      '';

      systemd.user.services.cave-mount = {
        Unit = {
          Description = "Mount cave with rclone";
          After = [ "network-online.target" ];
        };
        Service = {
          Type = "notify";
          ExecStartPre = "/usr/bin/env mkdir -p %h/cave";
          ExecStart = "${pkgs.rclone}/bin/rclone --config=%h/.config/rclone/rclone.conf --vfs-cache-mode writes --ignore-checksum mount \"cave:/mnt/data\" \"cave\"";
          ExecStop="/bin/fusermount -u %h/cave/%i";
        };
        Install.WantedBy = [ "default.target" ];
      };
  };

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
