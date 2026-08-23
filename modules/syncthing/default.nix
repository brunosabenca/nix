{ username, ... }:
{
  services.syncthing = {
    enable = true;
    user = username;
    group = "users";
    # The module only auto-creates /var/lib/syncthing (its default dataDir)
    # when `user` is left at its own default "syncthing" account; since we
    # run as a real user instead (so it can write into ~/Calibre on the
    # desktop hosts), point it at a directory that user already owns.
    dataDir = "/home/${username}/.local/share/syncthing";
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
