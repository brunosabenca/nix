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
    spotify
  ];

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="power_supply", KERNEL=="BAT0", ATTR{charge_control_start_threshold}="40", ATTR{charge_control_end_threshold}="80"
  '';

  home-manager.users.${username}.programs.fish.functions = {
    battery-full = {
      description = "Temporarily charge battery to 100%";
      body = "echo 100 | sudo tee /sys/class/power_supply/BAT0/charge_control_end_threshold > /dev/null";
    };
    battery-save = {
      description = "Restore battery charge thresholds to 40-80%";
      body = ''
        echo 40 | sudo tee /sys/class/power_supply/BAT0/charge_control_start_threshold > /dev/null
        echo 80 | sudo tee /sys/class/power_supply/BAT0/charge_control_end_threshold > /dev/null
      '';
    };
  };
}
