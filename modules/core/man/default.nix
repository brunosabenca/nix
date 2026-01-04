{
  pkgs,
  ...
}:
{
  documentation = {
    enable = true;
    dev.enable = true;
    man.enable = true;
    # This is very slow to rebuild
    # see https://discourse.nixos.org/t/slow-build-at-building-man-cache/52365/11
    man.generateCaches = false;
  };

  environment.systemPackages = with pkgs; [
    man-pages
    man-pages-posix
    tealdeer # simpler man with examples
    wikiman
  ];
}
