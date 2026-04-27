{
  username,
  ...
}:
{
  home-manager.users.${username} =
    {
      config,
      pkgs,
      ...
    }:
    {
      xdg.enable = true;

      xdg.portal = {
        enable = true;
        xdgOpenUsePortal = true;
        config = {
          common.default = [ "gnome" ];
        };
        extraPortals = [
          pkgs.xdg-desktop-portal-gnome
        ];
      };

      services.polkit-gnome.enable = true;

      dconf = {
        enable = true;
        settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
      };

      gtk = {
        enable = true;
        iconTheme = {
          name = "Papirus";
          package = pkgs.papirus-icon-theme;
        };
        gtk4.theme = config.gtk.theme;
      };
    };
}
