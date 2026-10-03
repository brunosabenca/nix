{
  lib,
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
}
