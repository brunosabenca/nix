{
  lib,
  pkgs,
  username,
  ...
}:
{
  home-manager.users.${username} = {
    programs.mpv = {
      enable = true;
      scripts = with pkgs.mpvScripts; [
        uosc
        sponsorblock
      ];
      config = {
        keep-open = "always";
        hwdec = "auto-safe";
        vo = "gpu";
        profile = "gpu-hq";
        gpu-context = "wayland";
        force-window = "immediate";
        interpolation = true;
        tscale = "oversample";
        video-sync = "display-resample";
        sub-font = lib.mkForce "Lexend Medium";
        sub-border-size = 1;
        sub-color = "#CDCDCD";
        # sub-shadow = 3;
        sub-shadow-color = "#000000";
        sub-shadow-offset = 2;
      };
    };
  };
}
