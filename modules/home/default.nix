{
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
      xdg.portal = {
        enable = true;
        xdgOpenUsePortal = true;
        config = {
          common.default = [ "gtk" ];
          common."org.freedesktop.impl.portal.FileChooser" = [ "termfilechooser" ];
        };
        extraPortals = [
          pkgs.xdg-desktop-portal-termfilechooser
          pkgs.xdg-desktop-portal-gtk
        ];
      };
      xdg.configFile = {
        "xdg-desktop-portal-termfilechooser/config" = {
          force = true;
          text = ''
            [filechooser]
            cmd=yazi-wrapper.sh
            default_dir=$HOME
            env=TERMCMD=kitty --title="terminal-filechooser" -e
            open_mode = suggested
            save_mode = last
          '';
        };
      };

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
        feishin # subsonic client
        pulseaudio # to use pactl
        deskflow
        bitwarden-desktop
        blueberry
        lm_sensors
        xdg-utils
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
        localsend

        oci-cli
        kubectl
        kubernetes-helm
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
        defaultApplications =
          let
            browser = "zen-beta.desktop";
            videoPlayer = "mpv.desktop";
            imageViewer = "okular.desktop";
          in
          {
            # "text/plain" = ["neovide.desktop"];
            "application/pdf" = [ "zathura.desktop" ];
            "image/jpeg" = [ imageViewer ];
            "image/png" = [ imageViewer ];
            "image/*" = [ imageViewer ];
            "video/png" = [ videoPlayer ];
            "video/jpg" = [ videoPlayer ];
            "video/*" = [ videoPlayer ];
            "text/html" = [ browser ];
            "x-scheme-handler/http" = [ browser ];
            "x-scheme-handler/https" = [ browser ];
            "x-scheme-handler/about" = [ browser ];
            "x-scheme-handler/unknown" = [ browser ];
          };
        associations.added = { };
      };
    };
}
