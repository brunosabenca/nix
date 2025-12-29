{
  config,
  lib,
  pkgs,
  home-manager,
  username,
  modulesPath,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  home-manager.users.${username} = {pkgs, ...}: {
  };

  networking = {
    hostName = "firefly";
    networkmanager.enable = true;
  };
}
