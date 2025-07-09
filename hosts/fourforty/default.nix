{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  services.openssh = {
    enable = true;
    ports = [22];
    settings = {
      PasswordAuthentication = true;
      AllowUsers = null; # Allows all users by default. Can be [ "user1" "user2" ]
      UseDns = true;
      X11Forwarding = false;
      PermitRootLogin = "prohibit-password"; # "yes", "without-password", "prohibit-password", "forced-commands-only", "no"
    };
  };
  services.kmonad = {
    enable = true;
    keyboards = {
      myKMonadOutput = {
        device = "/dev/input/by-path/platform-i8042-serio-0-event-kbd";
        config = (builtins.readFile ./miryoku_kmonad.kbd);
      };
    };
  };
  networking = {
    hostName = "fourforty";
    networkmanager.enable = true;
    firewall.allowedTCPPortRanges = [
      {
        from = 38843;
        to = 38843;
      }
      {
        from = 22;
        to = 22;
      }
    ];
    firewall.allowedUDPPortRanges = [
      {
        from = 38843;
        to = 38843;
      }
    ];
  };
  fileSystems."/mnt/cave" = {
    device = "bruno@192.168.1.30:/mnt/data";
    fsType = "fuse.sshfs";
    options = [
      "identityfile=${config.users.users.bruno.home}/.ssh/id_ed25519"
      "idmap=user"
      "x-systemd.automount" #< mount the filesystem automatically on first access
      "allow_other" #< don't restrict access to only the user which `mount`s it (because that's probably systemd who mounts it, not you)
      "user" #< allow manual `mount`ing, as ordinary user.
      "rw"
      "_netdev"
    ];
  };
  boot.supportedFilesystems."fuse.sshfs" = true;
}
