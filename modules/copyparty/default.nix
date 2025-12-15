{
  config,
  pkgs,
  copyparty,
  ...
}:
{
  age.secrets."copyparty.acme".file = ./copyparty.acme.age;

  age.secrets."copyparty.bruno" = {
    file = ./copyparty.bruno.age;
    mode = "770";
    owner = "copyparty";
    group = "copyparty";
  };

  services.copyparty = {
    enable = true;


    settings = {
      i = "0.0.0.0";
      p = [ 3921 3923 3945 3990 ];
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

  nixpkgs.overlays = [ copyparty.overlays.default ];
  environment.systemPackages = [
    pkgs.copyparty
  ];
}
