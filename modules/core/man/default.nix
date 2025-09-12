{
  inputs,
  home-manager,
  pkgs,
  username,
  ...
}:
{
  documentation.dev.enable = true;

  environment.systemPackages = with pkgs; [
    man-pages
    man-pages-posix
    tealdeer # simpler man with examples
    wikiman
  ];
}
