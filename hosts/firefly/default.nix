{
  config,
  lib,
  pkgs,
  home-manager,
  username,
  modulesPath,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  home-manager.users.${username} = {pkgs, ...}: {
      xdg.configFile."rclone/rclone-nixos.conf".text = ''
        [cave]
        type = sftp
        host = 192.168.1.83
        user = bruno
        key_file = ${config.users.users.bruno.home}/.ssh/id_ed25519
      '';

      systemd.user.services.mount-cave = {
        Unit = {
          Description = "Mount cave with rclone";
          After = [ "network-online.target" ];
        };
        Service = {
          ExecStartPre = "/run/current-system/sw/bin/mkdir -p ${config.users.users.bruno.home}/network/cave";
          ExecStart = "${pkgs.rclone}/bin/rclone --config=%h/.config/rclone/rclone-nixos.conf --vfs-cache-mode writes --ignore-checksum mount \"cave:/mnt/data\" \"%h/network/cave\"";
          ExecStop = "/run/current-system/sw/bin/fusermount -u %h/network/cave/%i";
          Environment = [ "PATH=/run/wrappers/bin/:$PATH" ];
        };
        Install.WantedBy = [ "default.target" ];
      };
  };

  services.kmonad = {
    enable = true;
    keyboards = {
      myKMonadOutput = {
        device = "/dev/input/by-path/platform-i8042-serio-0-event-kbd";
        config = (builtins.readFile ../../miryoku_kmonad.kbd);
      };
    };
  };

  networking = {
    hostName = "firefly";
    networkmanager.enable = true;
  };
}
