{
  username,
  ...
}:
{
  home-manager.users.${username} =
    {
      pkgs,
      lib,
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
        cloudflared
        feishin # subsonic client
        pulseaudio # to use pactl
        deskflow
        bitwarden-desktop
        lm_sensors
        xdg-utils
        sublime-merge
        discord
        btop
        scrcpy
        fortune
        darktable
        ansel
        rawtherapee
        gimp
        calibre
        obsidian
        freetube
        shellcheck
        awww
        zathura
        sxiv
        jhead
        telegram-desktop
        nvd
        wlogout
        filezilla
        # subtitle font via flag rather than a managed vlcrc, so VLC can still save its prefs
        (symlinkJoin {
          inherit (vlc) name;
          meta.mainProgram = "vlc";
          paths = [ vlc ];
          nativeBuildInputs = [ makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/vlc --add-flag "--freetype-font=Lexend Medium"
            # desktop entry execs the unwrapped binary by absolute path
            rm $out/share/applications/vlc.desktop
            sed "s|${vlc}/bin/vlc|$out/bin/vlc|" ${vlc}/share/applications/vlc.desktop \
              > $out/share/applications/vlc.desktop
          '';
        })
        easyeffects
        localsend
        fooyin
        lftp
        heroic
        file-roller
        geeqie

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
        ".config/wireplumber/wireplumber.conf.d/51-bluez-config.conf".text = ''
          monitor.bluez.properties = {
            bluez5.enable-sbc-xq = true
            bluez5.enable-msbc = true
            bluez5.enable-hw-volume = true
            bluez5.headset-roles = [ hsp_hs hsp_ag hfp_hf hfp_ag ]
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
            browser = "firefox.desktop";
            videoPlayer = "mpv.desktop";
            imageViewer = "qimgv.desktop";
            editor = "Neovim.desktop";
            # Calibre claims text/plain among others; keep it for real ebook formats only
            textTypes = [
              "text/plain"
              "text/markdown"
              "text/csv"
              "text/css"
              "text/javascript"
              "text/x-log"
              "text/x-python"
              "text/x-csrc"
              "text/x-chdr"
              "text/x-c++src"
              "text/x-c++hdr"
              "text/x-java"
              "text/x-makefile"
              "text/x-tex"
              "text/x-lua"
              "text/x-nix"
              "text/rust"
              "text/x-shellscript"
              "application/x-shellscript"
              "application/json"
              "application/x-yaml"
              "application/yaml"
              "application/toml"
              "application/xml"
              "application/x-desktop"
              "application/x-wine-extension-ini"
              "application/sql"
              "application/x-subrip"
            ];
          in
          lib.genAttrs textTypes (_: [ editor ])
          // {
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
