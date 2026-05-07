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

  systemd.services.battery-restore-thresholds = {
    description = "Restore battery charge thresholds to custom 50-80% after full charge";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.libsmbios}/bin/smbios-battery-ctl --set-charging-mode=custom --set-custom-charge-interval=50 80";
    };
  };

  services.udev.extraRules = ''
    ACTION=="change", SUBSYSTEM=="power_supply", KERNEL=="BAT0", ATTR{status}=="Full", TAG+="systemd", ENV{SYSTEMD_WANTS}="battery-restore-thresholds.service"
  '';

  home-manager.users.${username}.programs.fish.functions = {
    battery-full = {
      description = "Temporarily charge battery to 100%";
      body = "sudo smbios-battery-ctl --set-charging-mode=standard";
    };
    battery-save = {
      description = "Restore battery charge thresholds to firmware defaults (50-80%)";
      body = "sudo smbios-battery-ctl --set-charging-mode=custom --set-custom-charge-interval=50 80";
    };
  };
}
