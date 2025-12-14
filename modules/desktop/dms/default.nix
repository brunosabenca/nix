{
  ...
}:
{
  programs.dms-shell = {
    enable = true;
    systemd = {
      restartIfChanged = true;
    };
  };

  services.displayManager = {
    dms-greeter = {
      enable = true;
      compositor.name = "niri";
    };
  };
}
