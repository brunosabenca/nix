{
  config,
  pkgs,
  copyparty,
  ...
}:
{

  nixpkgs.overlays = [ copyparty.overlays.default ];
  environment.systemPackages = [
    pkgs.copyparty
  ];
  services.copyparty.enable = true;

  age.secrets."copyparty.acme".file = ./copyparty.acme.age;

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
