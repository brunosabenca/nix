{
  inputs,
  lib,
  config,
  pkgs,
  commands,
  ...
}:
{
  home.packages = with pkgs; [
    lm_sensors
    xdg-utils
    htop
    btop
    fortune
    shellcheck
    ranger
    jq
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
  };
}
