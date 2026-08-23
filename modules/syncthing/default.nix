{ username, ... }:
{
  services.syncthing = {
    enable = true;
    user = username;
    group = "users";
    guiAddress = "0.0.0.0:8384";
    openDefaultPorts = true;

    # Devices/folders are being paired via the web GUI for now (cave as
    # introducer). Once every host's device ID is known, declare
    # settings.devices/folders fully here and drop these two overrides
    # (their defaults are both `true`, i.e. fully declarative).
    overrideDevices = false;
    overrideFolders = false;
  };
}
