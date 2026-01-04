{
  inputs,
  lib,
  username,
  ...
}:
{
  nixpkgs.overlays = [
    (self: super: {
      mpv = super.mpv.override {
        # updated from mpv-unwrapped.wrapper in https://github.com/NixOS/nixpkgs/pull/474601
        scripts = with self.mpvScripts; [
          uosc
          sponsorblock
        ];

        extraMakeWrapperArgs = [
          "--add-flags"
          "--keep-open=always"
        ];
      };
    })
  ];

  home-manager.users.${username} = {
    imports = [
      inputs.catppuccin.homeModules.catppuccin
    ];

    catppuccin.mpv.enable = false;

    programs.mpv = {
      enable = true;
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
