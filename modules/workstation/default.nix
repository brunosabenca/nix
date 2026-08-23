{ pkgs, ... }:
{
  imports = [
    ../core/pkgs
    ../core/mpv
    ../core/audio
  ];

  hardware.bluetooth = {
    enable = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
        AutoEnable = true;
        ControllerMode = "dual";
      };
      General.UserspaceHID = true;
    };
    powerOnBoot = true;
  };

  fonts = {
    enableDefaultPackages = true;
    fontconfig = {
      antialias = true;
      hinting = {
        enable = true;
        autohint = true;
      };
      subpixel.rgba = "rgb";
    };
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
    ];
  };

  programs.partition-manager.enable = true;
  services.gvfs.enable = true; # Mount, trash, and other functionalities
  services.tumbler.enable = true; # Thumbnail support for images
}
