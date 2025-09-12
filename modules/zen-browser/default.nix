{
  inputs,
  config,
  pkgs,
  username,
  ...
}:
{
  config.home-manager.users.${username} =
    {
      pkgs,
      config,
      ...
    }:
    let
      profileName = "${username}";
    in
    {
      imports = [
        inputs.zen-browser.homeModules.beta
      ];

      programs.zen-browser.enable = true;
      programs.zen-browser.policies =
        let
          mkExtensionSettings = builtins.mapAttrs (
            _: pluginId: {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/${pluginId}/latest.xpi";
              installation_mode = "force_installed";
            }
          );
        in
        {
          AutofillAddressEnabled = true;
          AutofillCreditCardEnabled = false;
          DisableAppUpdate = true;
          DisableFeedbackCommands = true;
          DisableFirefoxStudies = true;
          DisablePocket = true;
          DisableTelemetry = true;
          DontCheckDefaultBrowser = true;
          NoDefaultBookmarks = true;
          OfferToSaveLogins = false;
          EnableTrackingProtection = {
            Value = true;
            Locked = true;
            Cryptomining = true;
            Fingerprinting = true;
          };
          ExtensionSettings = mkExtensionSettings {
            "extension@ublock.com" = "ublock-origin";
          };
        };

      programs.zen-browser.profiles.${profileName} = {
        settings = {
          "zen.welcome-screen.seen" = true;
        };
      };

      stylix.targets.zen-browser.profileNames = [ "${username}" ];
    };
}
