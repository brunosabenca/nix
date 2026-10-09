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

  services.syncthing.settings.folders."calibre".path = "/home/${username}/Calibre";

  nix.settings.cores = 6;

  # patool's test suite fails on python3.14 (tarfile now guesses MIME types
  # for compressed tar members differently), which breaks the bottles build
  # since it depends on patool for archive extraction.
  nixpkgs.overlays = [
    (final: prev: {
      python3Packages = prev.python3Packages.overrideScope (
        pyFinal: pyPrev: {
          patool = pyPrev.patool.overridePythonAttrs (old: {
            doCheck = false;
          });
        }
      );
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

      services.easyeffects.enable = false;
    };

  # plugdev is a Debian convention referenced in qmk-udev-rules; uaccess handles
  # actual device access, but the group must exist to silence the udevd warning.
  users.groups.plugdev = { };
  users.users.${username}.extraGroups = lib.mkAfter [
    "plugdev"
    "libvirtd"
  ];

  services.udev = {
    extraRules = ''
      ACTION=="add|change", KERNEL=="nvme[0-9]*n[0-9]*", ENV{DEVTYPE}=="disk", ATTR{queue/scheduler}="kyber"
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

  # monolith is wired to cave's LAN, so use NFS (cave exports to this IP only)
  services.mount-cave = {
    backend = "nfs";
    host = "192.168.1.236";
  };

  services.sunshine = {
    enable = true;
    openFirewall = true;
    capSysAdmin = true;
  };

  hardware.enableRedistributableFirmware = true;
  hardware.wirelessRegulatoryDatabase = true;

  networking = {
    hostName = "monolith";
    networkmanager = {
      enable = true;
      wifi.powersave = false;
    };
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
    "vm.dirty_background_bytes" = 67108864; # 64MB - start background writeback
    "vm.dirty_bytes" = 536870912; # 512MB - writers block above this
    # Suspend allocates with reclaim restricted. With the page cache filling RAM
    # the amdgpu/nvme/xhci resume paths hit ENOMEM, the NVMe got disabled and
    # root went read-only, hanging the machine on wake.
    "vm.min_free_kbytes" = 524288; # 512MB - keep headroom for suspend/resume
  };

  boot.supportedFilesystems = [
    "ntfs"
    "fuse.sshfs"
  ];

  boot.extraModprobeConfig = ''
    options uvcvideo quirks=0x20
    options cfg80211 ieee80211_regdom=GB
  '';

  hardware.graphics = {
    enable = true;
  };

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  # swtpm emulates a TPM 2.0 device, required by Windows 11.
  virtualisation.libvirtd = {
    enable = true;
    qemu.swtpm.enable = true;
  };
  virtualisation.spiceUSBRedirection.enable = true;
  programs.virt-manager.enable = true;

  environment.systemPackages = with pkgs; [
    distrobox
    spotify
    lmstudio
    grayjay
  ];

  # environment.etc, not systemPackages: system-path's buildEnv only links a
  # whitelist of subpaths and silently drops bare top-level files like this.
  environment.etc."virtio-win.iso".source = pkgs.virtio-win.src;

  zramSwap = {
    enable = true;
    memoryPercent = 50;
    algorithm = "zstd";
  };

  # earlyoom only fires when RAM *and* swap are both nearly gone, so a leaking
  # Electron app can thrash through 16GB of swap for minutes first. oomd kills
  # on memory pressure (PSI) instead, which catches the stall as it starts.
  systemd.oomd = {
    enable = true;
    enableUserSlices = true;
    extraConfig = {
      DefaultMemoryPressureDurationSec = "20s";
    };
  };
  systemd.slices."user-".sliceConfig.ManagedOOMMemoryPressureLimit = "50%";

  services.earlyoom = {
    enable = true;
    freeMemThreshold = 5;
    freeSwapThreshold = 5;
    enableNotifications = true;
    # Patterns match /proc/<pid>/comm, which is truncated to 15 chars, so
    # wrapped binaries look like ".Discord-wrappe" and need prefix matches.
    extraArgs = [
      "--prefer"
      # Big, leaky, or cheap to restart: LLM server, Electron chat/notes, browsers
      "^(\\.Discord-wrapp|vesktop|\\.vesktop-wrapp|lmstudio|\\.lmstudio|LM Studio|\\.firefox-wrapp|WebExtensions|Isolated Web Co|telegram-desktop|\\.telegram-deskt|\\.obsidian-wrapp|freetube|\\.freetube-wrapp|heroic|\\.heroic-wrapped|filezilla|calibre|gimp|darktable|rawtherapee)"
      "--avoid"
      # Session, audio, terminal and anything holding data you can't redo
      "^(niri|\\.noctalia-wrapp|systemd|greetd|pipewire|pipewire-pulse|wireplumber|Xwayland|\\.kitty-wrapped|kitten|fish|zsh|claude|\\.claude-unwrapp|syncthing|\\.tailscaled-wra|steam|bwrap|srt-bwrap)$"
    ];
  };

  services.xserver.dpi = 108;
  services.xserver.videoDrivers = [ "amdgpu" ];

  # Needed for corectrl
  hardware.amdgpu.overdrive.enable = true;

  # MSI B450I's Nuvoton Super I/O exposes the CPU/case fan headers; without
  # this driver nothing but the GPU fan is visible or controllable.
  boot.kernelModules = [ "nct6775" ];

  # Fan curves for silence (CPU/case/GPU) are configured in its GUI.
  programs.coolercontrol.enable = true;

  # Seed-once copy of the tuned fan curves: "C" copies only if the target is
  # absent, so GUI edits stay writable. After tuning, copy
  # /etc/coolercontrol/config.toml back over coolercontrol.toml to keep this current.
  systemd.tmpfiles.rules = [
    "d /etc/coolercontrol 0755 root root -"
    "C /etc/coolercontrol/config.toml 0644 root root - ${./coolercontrol.toml}"
  ];

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
      protontricks.enable = true;
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
