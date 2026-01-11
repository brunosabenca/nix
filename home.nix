{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    cloudflared
    lm_sensors
    xdg-utils
    htop
    btop
    fortune
    shellcheck
    jq
  ];
}
