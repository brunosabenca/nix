{
  config,
  lib,
  pkgs,
  home-manager,
  username,
  modulesPath,
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
      home.packages = [ pkgs.rclone ];
      xdg.configFile."rclone/rclone-nixos.conf".text = ''
        [cave]
        type = sftp
        host = 192.168.1.30
        user = bruno
        key_file = ${config.users.users.bruno.home}/.ssh/id_ed25519
      '';

      systemd.user.services.mount-cave = {
        Unit = {
          Description = "Mount cave with rclone";
          After = [ "network-online.target" ];
        };
        Service = {
          ExecStartPre = "/run/current-system/sw/bin/mkdir -p ${config.users.users.bruno.home}/cave";
          ExecStart = "${pkgs.rclone}/bin/rclone --config=%h/.config/rclone/rclone-nixos.conf --vfs-cache-mode writes --ignore-checksum mount \"cave:/mnt/data\" \"cave\"";
          ExecStop = "/run/current-system/sw/bin/fusermount -u %h/cave/%i";
          Environment = [ "PATH=/run/wrappers/bin/:$PATH" ];
        };
        Install.WantedBy = [ "default.target" ];
      };

      services.kdeconnect.enable = true;
    };

  services.openssh = {
    enable = true;
    ports = [ 22 ];
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
      {
        from = 24800;
        to = 24800;
      }
    ];
  };
}
