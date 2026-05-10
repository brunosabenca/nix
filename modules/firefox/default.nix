{
  username,
  ...
}:
{
  config.home-manager.users.${username} =
    {
      pkgs,
      ...
    }:
    {
      stylix.targets.firefox = {
        enable = true;
        profileNames = [ "main" ];
        colorTheme.enable = true;
      };

      programs.firefox.enable = true;
      programs.firefox.profiles.main = {
        id = 0;

        extensions.force = true;
        extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
          bitwarden
          clearurls
          ublock-origin
          consent-o-matic
          firefox-color
        ];

        search = {
          default = "ddg";
          engines = {
            google.metaData.hidden = true;
            google.metaData.alias = "@g";

            wikipedia.metaData.hidden = true;
            bing.metaData.hidden = true;
            ebay.metaData.hidden = true;

            "Nix Packages" = {
              urls = [
                {
                  template = "https://search.nixos.org/packages";
                  params = [
                    {
                      name = "type";
                      value = "packages";
                    }
                    {
                      name = "query";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "@np" ];
            };

            "Nix Options" = {
              urls = [
                {
                  template = "https://search.nixos.org/options";
                  params = [
                    {
                      name = "type";
                      value = "options";
                    }
                    {
                      name = "query";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "@no" ];
            };

            "NixOS Wiki" = {
              urls = [ { template = "https://nixos.wiki/index.php?search={searchTerms}"; } ];
              icon = "https://nixos.wiki/favicon.png";
              updateInterval = 24 * 60 * 60 * 1000;
              definedAliases = [ "@nw" ];
            };
          };
          force = true;
          order = [
            "ddg"
            "google"
          ];
        };

        settings = {
          "browser.privatebrowsing.vpnpromourl" = "";
          "datareporting.healthreport.uploadEnabled" = false;
          "extensions.pocket.enabled" = false;
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
          "app.normandy.enabled" = false;
          "signon.firefoxRelay.feature" = "disabled";
          "extensions.formautofill.addresses.enabled" = false;

          "browser.aboutConfig.showWarning" = false;

          # Open previous windows and tabs
          "browser.startup.page" = 3;

          "browser.tabs.closeWindowWithLastTab" = false;
          # Warn when attempting to close a window with multiple tabs
          "browser.tabs.warnOnClose" = true;
          "signon.rememberSignons" = false;
          "dom.security.https_only_mode" = true;

          "extensions.update.enabled" = false;

          # Use userChrome.css
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        };
      };
    };
}
