{
  config,
  lib,
  pkgs,
  ...
}:
{
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
}
