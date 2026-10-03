{ config, pkgs, ... }:
let
  port = 8088;
  stateDir = "/var/lib/kindle-calendar";
  # Weather location (Open-Meteo). Defaults to central London; change as needed.
  latitude = "51.5072";
  longitude = "-0.1276";
  lexend = "${pkgs.lexend}/share/fonts/truetype/lexend/lexend";
  python = pkgs.python3.withPackages (ps: [
    ps.icalendar
    ps.recurring-ical-events
    ps.pillow
  ]);
in
{
  # The Google Calendar "secret address in iCal format" URL. Create with:
  #   agenix -e modules/kindle-calendar/ics-url.age
  age.secrets."kindle-calendar-ics-url".file = ./ics-url.age;

  users.users.kindle-calendar = {
    isSystemUser = true;
    group = "kindle-calendar";
  };
  users.groups.kindle-calendar = { };

  systemd.services.kindle-calendar = {
    description = "Render calendar to a PNG for the Kindle";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      User = "kindle-calendar";
      Group = "kindle-calendar";
      StateDirectory = "kindle-calendar";
      StateDirectoryMode = "0755";
      # Private (not served) copy of the last good calendar feed.
      CacheDirectory = "kindle-calendar";
      CacheDirectoryMode = "0700";
      LoadCredential = "ics-url:${config.age.secrets."kindle-calendar-ics-url".path}";
      # 1072x1448 is the Paperwhite 4 (10th gen); the 11th gen is 1236x1648.
      ExecStart = ''
        ${python}/bin/python ${./render.py} \
          --out ${stateDir}/calendar.png \
          --width 1072 --height 1448 \
          --tz ${config.time.timeZone} \
          --lat ${latitude} --lon ${longitude} \
          --font ${lexend}/Lexend-Regular.ttf \
          --font-bold ${lexend}/Lexend-Bold.ttf
      '';
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      NoNewPrivileges = true;
    };
  };

  # A finished oneshot isn't restarted by `nixos-rebuild switch`, so the PNG
  # would stay stale until the next timer tick. This unit is restarted whenever
  # kindle-calendar.service's definition changes (renderer, fonts, arguments)
  # and, on boot, renders straight away.
  systemd.services.kindle-calendar-rerender = {
    description = "Re-render the Kindle calendar after a config change";
    wantedBy = [ "multi-user.target" ];
    restartTriggers = [ config.systemd.units."kindle-calendar.service".unit ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.systemd}/bin/systemctl start kindle-calendar.service";
    };
  };

  systemd.timers.kindle-calendar = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      # Every 5 minutes on the clock, so the PNG is at most 5 minutes old when
      # the Kindle wakes at :00/:30.
      OnCalendar = "*:0/5";
      Persistent = true;
    };
  };

  # The Kindle can't join the tailnet, so serve plain HTTP on the LAN. Tailnet
  # access is the tailscale serve mapping in hosts/cave/default.nix.
  services.nginx.virtualHosts."kindle-calendar" = {
    listen = [
      {
        addr = "0.0.0.0";
        inherit port;
      }
    ];
    root = stateDir;
    extraConfig = ''
      allow 127.0.0.1; # tailscale serve proxies from loopback
      allow 10.0.0.0/8;
      allow 172.16.0.0/12;
      allow 192.168.0.0/16;
      deny all;
    '';
  };

  networking.firewall.allowedTCPPorts = [ port ];
}
