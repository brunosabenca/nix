# https://github.com/estebanheish/dots/blob/master/modules/nixos/qbittorrent-service/default.nix
{ config, pkgs, ... }:
let
  qbit-nox = pkgs.qbittorrent.override {
    guiSupport = false;
    webuiSupport = true;
  };
  port = 6881;
  tailscale = config.services.tailscale.package;
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

  systemd.services.qbit-tailscale-serve = {
    description = "Expose qBittorrent WebUI over HTTPS via Tailscale Serve";
    after = [
      "tailscaled.service"
      "qbit.service"
    ];
    wants = [ "tailscaled.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${tailscale}/bin/tailscale serve --bg --https=443 http://127.0.0.1:${toString port}";
      ExecStop = "${tailscale}/bin/tailscale serve reset";
    };
  };

  networking.firewall.interfaces.${config.services.tailscale.interfaceName}.allowedTCPPorts = [ 443 ];
}
