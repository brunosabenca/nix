{
  config,
  lib,
  pkgs,
  username,
  ...
}:
let
  cfg = config.services.mount-cave;
  userHome = config.users.users.${username}.home;
in
{
  options.services.mount-cave = {
    mountPoint = lib.mkOption {
      type = lib.types.str;
      default = "network/cave";
      description = "Path relative to home directory where cave will be mounted";
    };

    backend = lib.mkOption {
      type = lib.types.enum [
        "rclone"
        "nfs"
      ];
      default = "rclone";
      description = ''
        How to mount cave. "nfs" is fastest but only works on cave's LAN (it is
        exported to specific LAN addresses). "rclone" goes over SSH, so it also
        works through Tailscale from anywhere.
      '';
    };

    host = lib.mkOption {
      type = lib.types.str;
      default = "cave";
      description = "Address of cave. The default is its Tailscale (MagicDNS) name.";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.backend == "nfs") {
      # NFS (AUTH_SYS) checks the client's uid/gids against numeric ownership on
      # cave. Mirror cave's qbit IDs (see modules/nixos/qbittorrent-service) so
      # names resolve and joining the group gives write access to its files.
      users.users.qbit = {
        uid = 989;
        group = "qbit";
        isSystemUser = true;
      };
      users.groups.qbit.gid = 985;
      users.users.${username}.extraGroups = [ "qbit" ];

      fileSystems."/home/${username}/${cfg.mountPoint}" = {
        device = "${cfg.host}:/mnt/data";
        fsType = "nfs";
        options = [
          "nfsvers=4.2"
          "_netdev"
          "noauto"
          "nofail"
          # Mounted on first access, so there is no boot-time race with the network
          "x-systemd.automount"
          "x-systemd.idle-timeout=10min"
          "x-systemd.mount-timeout=15s"
          # Files lists this entry and mounts it as the user, which needs `user`
          # plus the setuid mount.nfs wrapper below
          "user"
        ];
      };
      security.wrappers."mount.nfs" = {
        setuid = true;
        owner = "root";
        group = "root";
        source = "${pkgs.nfs-utils}/bin/mount.nfs";
      };
    })

    (lib.mkIf (cfg.backend == "rclone") {
      home-manager.users.${username} =
        { pkgs, lib, ... }:
        {
          home.packages = [ pkgs.rclone ];

          # Write as a real file (not a nix store symlink) so rclone can save config updates
          home.activation.rcloneNixosConf = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            install -Dm600 ${pkgs.writeText "rclone-nixos.conf" ''
              [cave]
              type = sftp
              host = ${cfg.host}
              user = bruno
              key_file = ${userHome}/.ssh/id_ed25519
            ''} "$HOME/.config/rclone/rclone-nixos.conf"
          '';

          systemd.user.services.mount-cave = {
            Unit = {
              Description = "Mount cave with rclone";
              After = [ "network-online.target" ];
            };
            Service = {
              ExecStartPre = "/run/current-system/sw/bin/mkdir -p ${userHome}/${cfg.mountPoint}";
              ExecStart = "${pkgs.rclone}/bin/rclone --config=%h/.config/rclone/rclone-nixos.conf --vfs-cache-mode writes --ignore-checksum --dir-cache-time 30s mount \"cave:/mnt/data\" \"${cfg.mountPoint}\"";
              ExecStop = "/run/current-system/sw/bin/fusermount -u %h/${cfg.mountPoint}";
              Environment = [ "PATH=/run/wrappers/bin/:$PATH" ];
              # User units can't order after the system's network-online.target, so
              # retry until the network is actually up.
              Restart = "on-failure";
              RestartSec = 10;
            };
            Install.WantedBy = [ "default.target" ];
          };
        };
    })
  ];
}
