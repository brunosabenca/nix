{
  config,
  pkgs,
  lib,
  username,
  ...
}:
let
  mountPoint = config.services.mount-cave.mountPoint;
  userHome = config.users.users.${username}.home;
in
{
  options.services.mount-cave.mountPoint = lib.mkOption {
    type = lib.types.str;
    default = "cave";
    description = "Path relative to home directory where cave will be mounted";
  };

  config.home-manager.users.${username} =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.rclone ];

      xdg.configFile."rclone/rclone-nixos.conf".text = ''
        [cave]
        type = sftp
        host = 192.168.1.83
        user = bruno
        key_file = ${userHome}/.ssh/id_ed25519
      '';

      systemd.user.services.mount-cave = {
        Unit = {
          Description = "Mount cave with rclone";
          After = [ "network-online.target" ];
        };
        Service = {
          ExecStartPre = "/run/current-system/sw/bin/mkdir -p ${userHome}/${mountPoint}";
          ExecStart = "${pkgs.rclone}/bin/rclone --config=%h/.config/rclone/rclone-nixos.conf --vfs-cache-mode writes --ignore-checksum mount \"cave:/mnt/data\" \"${mountPoint}\"";
          ExecStop = "/run/current-system/sw/bin/fusermount -u %h/${mountPoint}";
          Environment = [ "PATH=/run/wrappers/bin/:$PATH" ];
        };
        Install.WantedBy = [ "default.target" ];
      };
    };
}
