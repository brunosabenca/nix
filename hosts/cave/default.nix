{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./audio-configuration.nix
  ];

  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
    AllowHybridSleep=no
    AllowSuspendThenHibernate=no
  '';

  age.secrets."cloudflared".file = ./cloudflared.age;

  services.cloudflared = {
    enable = true;
    tunnels = {
      "33acef66-7c08-48a8-916f-75b913578957" = {
        credentialsFile = config.age.secrets."cloudflared".path;
        default = "http_status:404";
      };
    };
  };

  services.getty.autologinUser = "bruno";

  systemd.services.navidrome.serviceConfig = {
    ProtectHome = lib.mkForce false;
    BindReadOnlyPaths = [
      "/etc"
      "/mnt/data/Music"
    ];
  };

  services.navidrome = {
    enable = true;
    user = "navidrome";
    group = "users";
    settings = {
      musicFolder = "/mnt/data/Music";
    };
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

  age.secrets."navidrome.acme".file = ./navidrome.acme.age;

  security.acme.certs."navidrome.brunosabenca.com" = {
    dnsProvider = "cloudflare";
    credentialsFile = config.age.secrets."navidrome.acme".path;
    group = config.services.nginx.group;
  };

  services.nginx = {
    enable = true;
    virtualHosts = {
      "navidrome.brunosabenca.com" = {
        useACMEHost = "navidrome.brunosabenca.com";
        forceSSL = true;
        locations."/".proxyPass = "http://127.0.0.1:4533";
      };
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "admin+acme@brunosabenca.com";
  };

  networking = {
    hostName = "cave";
    networkmanager.enable = true;

    firewall.allowedTCPPortRanges = [
      {
        from = 38844;
        to = 38844;
      }
      {
        from = 22;
        to = 22;
      }
      {
        from = 80;
        to = 80;
      }
      {
        from = 443;
        to = 443;
      }
      {
        from = 4533;
        to = 4533;
      }
    ];
    firewall.allowedUDPPortRanges = [
      {
        from = 4533;
        to = 4533;
      }
      {
        from = 38844;
        to = 38844;
      }
    ];
  };
  powerManagement.cpuFreqGovernor = "performance";

  services.acpid.enable = true;
  hardware.sensor.iio.enable = true;

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
    ];
  };

  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = [ "*" ];
        extraConfig = ''
          [main]
          f1 = back
          f2 = forward
          f3 = refresh
          f4 = f11
          f5 = scale
          f6 = brightnessdown
          f7 = brightnessup
          f8 = mute
          f9 = volumedown
          f10 = volumeup

          back = back
          forward = forward
          refresh = refresh
          zoom = f11
          scale = scale
          brightnessdown = brightnessdown
          brightnessup = brightnessup
          mute = mute
          volumedown = volumedown
          volumeup = volumeup

          f13=coffee
          sleep=coffee

          [meta]
          f1 = f1
          f2 = f2
          f3 = f3
          f4 = f4
          f5 = f5
          f6 = f6
          f7 = f7
          f8 = f8
          f9 = f9
          f10 = f10

          back = f1
          forward = f2
          refresh = f3
          zoom = f4
          scale = f5
          brightnessdown = f6
          brightnessup = f7
          mute = f8
          volumedown = f9
          volumeup = f10


          [alt]
          backspace = delete
          brightnessdown = kbdillumdown
          brightnessup = kbdillumup
          f6 = kbdillumdown
          f7 = kbdillumup

          [control]
          f5 = sysrq
          scale = sysrq

          [control+alt]
          backspace = C-A-delete

        '';
      };
    };
  };
}
