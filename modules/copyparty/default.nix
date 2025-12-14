{
  config,
  pkgs,
  username,
  copyparty,
  ...
}:
{
  home-manager.users.${username} =
    {
      age,
      config,
      ...
    }:
    {
      age.secrets."copyparty.bruno".file = ./copyparty.bruno.age;

    };

  services.copyparty = {
    enable = true;
    # directly maps to values in the [global] section of the copyparty config.
    # see `copyparty --help` for available options
    settings = {
      i = "0.0.0.0";
      # use lists to set multiple values
      p = [
        3923
      ];
      # use booleans to set binary flags
      no-reload = true;
      # using 'false' will do nothing and omit the value when generating a config
      ignored-flag = false;
    };

    accounts = {
      bruno.passwordFile = config.age.secrets."copyparty.bruno".path;
    };

    volumes = {
      "/" = {
        path = "/mnt/data";
        # see `copyparty --help-accounts` for available options
        access = {
          # users "ed" and "k" get read-write
          rw = [
            "bruno"
          ];
        };
        # see `copyparty --help-flags` for available options
        flags = {
          # "fk" enables filekeys (necessary for upget permission) (4 chars long)
          fk = 4;
          # scan for new files every 60sec
          scan = 60;
          # volflag "e2d" enables the uploads database
          e2d = true;
          # "d2t" disables multimedia parsers (in case the uploads are malicious)
          d2t = true;
          # skips hashing file contents if path matches *.iso
          nohash = "\.iso$";
        };
      };
    };
    # you may increase the open file limit for the process
    openFilesLimit = 8192;
  };

  age.secrets."copyparty.acme".file = ./copyparty.acme.age;

  nixpkgs.overlays = [ copyparty.overlays.default ];
  environment.systemPackages = [
    pkgs.copyparty
  ];

  security.acme.certs."copyparty.brunosabenca.com" = {
    dnsProvider = "cloudflare";
    credentialsFile = config.age.secrets."copyparty.acme".path;
    group = config.services.nginx.group;
  };

  services.nginx = {
    enable = true;
    virtualHosts = {
      "copyparty.brunosabenca.com" = {
        useACMEHost = "copyparty.brunosabenca.com";
        forceSSL = true;
        locations."/".proxyPass = "http://127.0.0.1:3923";
      };
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "admin+acme@brunosabenca.com";
  };
}
