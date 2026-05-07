{
  pkgs,
  username,
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
    libsmbios
    spotify
  ];

  home-manager.users.${username}.programs.fish.functions = {
    battery-full = {
      description = "Temporarily charge battery to 100%";
      body = "sudo smbios-battery-ctl --set-charging-cfg=standard";
    };
    battery-save = {
      description = "Restore battery charge thresholds to firmware defaults (50-80%)";
      body = "sudo smbios-battery-ctl --set-charging-cfg=custom,50,80";
    };
  };
}
