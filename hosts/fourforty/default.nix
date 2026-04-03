{
  config,
  lib,
  pkgs,
  home-manager,
  username,
  modulesPath,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  home-manager.users.${username} =
    {
      pkgs,
      ...
    }:
    {
      home.packages = [ pkgs.vial ];

      services.kdeconnect.enable = true;
    };

  services.udev = {

    packages = with pkgs; [
      qmk
      qmk-udev-rules
      qmk_hid
      via
      vial
    ]; # packages

  }; # udev

  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      PasswordAuthentication = true;
      AllowUsers = null; # Allows all users by default. Can be [ "user1" "user2" ]
      UseDns = true;
      X11Forwarding = false;
      PermitRootLogin = "prohibit-password"; # "yes", "without-password", "prohibit-password", "forced-commands-only", "no"
    };
  };
  networking = {
    hostName = "fourforty";
    networkmanager.enable = true;
    firewall.allowedTCPPortRanges = [
      {
        from = 38843;
        to = 38843;
      }
      {
        from = 22;
        to = 22;
      }
      {
        from = 24800;
        to = 24800;
      }
    ];
    firewall.allowedUDPPortRanges = [
      {
        from = 38843;
        to = 38843;
      }
      {
        from = 24800;
        to = 24800;
      }
    ];
  };
}
