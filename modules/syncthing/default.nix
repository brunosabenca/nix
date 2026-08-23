{ username, ... }:
{
  services.syncthing = {
    enable = true;
    user = username;
    group = "users";
    # module only auto-creates /var/lib/syncthing for its own default "syncthing" user
    dataDir = "/home/${username}/.local/share/syncthing";
    guiAddress = "0.0.0.0:8384";
    openDefaultPorts = true;

    # false while pairing via the GUI; flip to true (the defaults) once paired
    overrideDevices = false;
    overrideFolders = false;
  };
}
