{
  inputs,
  lib,
  config,
  pkgs,
  username,
  ...
}:
{
  home-manager.users.${username} = {
    imports = [
      inputs.catppuccin.homeModules.catppuccin
    ];

    catppuccin.mpv.enable = false;

    programs.mpv = {
      enable = true;
      package = (
        pkgs.mpv-unwrapped.wrapper {
          scripts = with pkgs.mpvScripts; [
            uosc
            sponsorblock
          ];

          mpv = pkgs.mpv-unwrapped.override {
            waylandSupport = true;
          };
        }
      );
      config = {
        hwdec = "auto-safe";
        vo = "gpu";
        profile = "gpu-hq";
        gpu-context = "wayland";
        force-window = "immediate";
        interpolation = true;
        tscale = "oversample";
        video-sync = "display-resample";
        sub-font = lib.mkForce "Gandhi Sans Bold";
        sub-border-size = 1;
        sub-color = "#CDCDCD";
        # sub-shadow = 3;
        sub-shadow-color = "#000000";
        sub-shadow-offset = 2;
      };
    };
  };
}
