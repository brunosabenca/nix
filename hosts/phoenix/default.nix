{
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

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
