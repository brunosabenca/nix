{
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  networking = {
    hostName = "firefly";
    networkmanager.enable = true;
  };

  environment.systemPackages = with pkgs; [
    distrobox
    spotify
  ];
}
