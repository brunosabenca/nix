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
  };

  networking = {
    hostName = "firefly";
    networkmanager.enable = true;
  };
}
