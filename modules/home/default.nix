{
  inputs,
  lib,
  config,
  pkgs,
  commands,
  username,
  ...
}:
{
  home-manager.users.${username} =
    {
      pkgs,
      ...
    }:
    {
      # allow fontconfig to discover fonts and configurations installed through home.packages
      fonts.fontconfig.enable = true;

      #dconf = {
      #  enable = true;
      #  settings."org/gnome/shell" = {
      #    disable-user-extensions = false;
      #    enabled-extensions = with pkgs.gnomeExtensions; [
      #      dash-to-panel.extensionUuid
      #      run-or-raise.extensionUuid
      #    ];
      #  };
      #};

      home.packages = with pkgs; [
        pulseaudio # to use pactl
        bitwarden-desktop
        blueberry
        lm_sensors
        xdg-utils
        firefox
        sublime-merge
        discord
        htop
        btop
        scrcpy
        fortune
        darktable
        ansel
        rawtherapee
        gimp
        telegram-desktop
        calibre
        obsidian
        freetube
        youtube-tui
        networkmanagerapplet
        shellcheck
        swww
        zathura
        sxiv
        jhead
        yazi
        jq
        nvd
        wlogout
        filezilla
        vlc
        easyeffects
        bitwarden

        oci-cli
        kubectl
        kubernetes-helm
        cloudflared
        kustomize

        phockup
        nomacs

        unar
        unrar-wrapper

        # used by ~/.config/hypr/scripts/screenshot.sh
        grimblast
        swappy

        bibata-cursors
        gruvbox-dark-icons-gtk
        adw-gtk3

        #emulationstation-de

        (catppuccin-kde.override {
          flavour = [ "mocha" ];
          accents = [ "lavender" ];
        })
        league-of-moveable-type
        font-awesome
        fira-sans
        powerline-fonts
        powerline-symbols
      ];

      home.file = {
        ".config/wireplumber/bluetooth.lua.d/51-bluez-config.lua".text = ''
          bluez_monitor.properties = {
          	["bluez5.enable-sbc-xq"] = true,
          	["bluez5.enable-msbc"] = true,
          	["bluez5.enable-hw-volume"] = true,
          	["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
          }
        '';
      };

      xdg.configFile."mimeapps.list".force = true;
      xdg.mimeApps = {
        enable = true;
        # Useful commands for debugging:
        # XDG_UTILS_DEBUG_LEVEL=2 xdg-mime query filetype example.png
        # XDG_UTILS_DEBUG_LEVEL=2 xdg-mime query default image/png
        defaultApplications = {
          # "text/plain" = ["neovide.desktop"];
          "application/pdf" = [ "zathura.desktop" ];
          "image/jpeg" = [ "okular.desktop" ];
          "image/png" = [ "okular.desktop" ];
          "image/*" = [ "okular.desktop" ];
          "video/png" = [ "mpv.desktop" ];
          "video/jpg" = [ "mpv.desktop" ];
          "video/*" = [ "mpv.desktop" ];
          "text/html" = [ "firefox.desktop" ];
          "x-scheme-handler/http" = [ "firefox.desktop" ];
          "x-scheme-handler/https" = [ "firefox.desktop" ];
          "x-scheme-handler/about" = [ "firefox.desktop" ];
          "x-scheme-handler/unknown" = [ "firefox.desktop" ];
        };
        associations.added = { };
      };
    };
}
