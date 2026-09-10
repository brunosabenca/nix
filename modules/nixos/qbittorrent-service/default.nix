# https://github.com/estebanheish/dots/blob/master/modules/nixos/qbittorrent-service/default.nix
{ pkgs, ... }:
let
  qbit-nox = pkgs.qbittorrent.override {
    guiSupport = false;
    webuiSupport = true;
  };
  port = 6881;
  setWebuiAddress = pkgs.writeShellScript "qbit-set-webui-address" ''
    mkdir -p /var/lib/qBittorrent/config
    ${pkgs.crudini}/bin/crudini --set /var/lib/qBittorrent/config/qBittorrent.conf Preferences 'WebUI\Address' 127.0.0.1
  '';
in
{
  systemd.services.qbit = {
    enable = true;
    description = "qBittorrent-nox service";
    documentation = [ "man:qbittorrent-nox(1)" ];
    wants = [ "network-online.target" ];
    after = [
      "network-online.target"
      "nss-lookup.target"
    ];

    serviceConfig = {
      Type = "simple";
      User = "qbit";
      Group = "qbit";
      StateDirectory = "qBittorrent";
      StateDirectoryMode = "0750";
      ExecStartPre = "${setWebuiAddress}";
      ExecStart = "${qbit-nox}/bin/qbittorrent-nox";
    };

    environment = {
      QBT_WEBUI_PORT = toString port;
      QBT_PROFILE = "/var/lib";
    };

    wantedBy = [ "multi-user.target" ];
  };

  users.users.qbit = {
    group = "qbit";
    isSystemUser = true;
  };
  users.groups.qbit = { };
}
