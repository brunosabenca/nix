{
  pkgs,
  config,
  ...
}:
{
  stylix = {
    enable = true;
    autoEnable = false;
    image = config.lib.stylix.pixel "base0A";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    fonts = {
      serif.name = "Noto Serif";
      sansSerif.name = "Noto Sans";
      monospace.name = "JetBrains Mono NF";

      sizes = {
        terminal = 12;
        applications = 10;
        popups = 10;
        desktop = 10;
      };
    };
  };
}
