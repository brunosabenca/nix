{pkgs, ...}: {
  services.minidlna = {
    enable = true;
    openFirewall = true;
    settings = {
      friendly_name = "SHH DLNA SERVER";
      media_dir = ["/mnt/data/"];
      inotify = "yes";
    };
  };
  users.users."minidlna" = {
    extraGroups = ["users"]; # so minidlna can access the files.
  };
  environment.systemPackages = [pkgs.inotify-tools];
}

