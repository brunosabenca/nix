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
  services.tailscale.enable = true;

  environment.systemPackages = [
    pkgs.distrobox
    pkgs.grayjay
    pkgs.spotify
  ];

  networking = {
    hostName = "phoenix";
    networkmanager.enable = true;
    firewall.allowedTCPPorts = [ 9030 ];
  };
}
