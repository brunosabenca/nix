{
  config,
  lib,
  pkgs,
  home-manager,
  username,
  modulesPath,
  inputs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  services.mount-cave.mountPoint = "network/cave";

  networking = {
    hostName = "firefly";
    networkmanager.enable = true;
  };

  environment.systemPackages = with pkgs; [
    distrobox
    spotify
  ];
}
