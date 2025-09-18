{
  config,
  lib,
  pkgs,
  ...
}:
{
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
}
