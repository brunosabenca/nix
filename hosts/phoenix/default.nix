{
  pkgs,
  username,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  services.syncthing.settings.folders."calibre".path = "/home/${username}/Calibre";

  environment.systemPackages = [
    pkgs.distrobox
    pkgs.spotify
  ];

  networking = {
    hostName = "phoenix";
    networkmanager.enable = true;
    firewall.allowedTCPPortRanges = [
      {
        from = 9030;
        to = 9030;
      }
    ];
  };
}
