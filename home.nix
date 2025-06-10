{
  inputs,
  lib,
  config,
  pkgs,
  commands,
  ...
}: {
  imports = [
    inputs.catppuccin.homeModules.catppuccin
  ];

  # allow fontconfig to discover fonts and configurations installed through home.packages
  fonts.fontconfig.enable = true;

  dconf = {
    enable = true;
    settings."org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = with pkgs.gnomeExtensions; [
        dash-to-panel.extensionUuid
        run-or-raise.extensionUuid
      ];
    };
  };

  home.packages = with pkgs; [
    blueberry
    lm_sensors
    xdg-utils
    firefox
    ungoogled-chromium
    spotify
    sublime-merge
    discord
    tor-browser
    htop
    btop
    scrcpy
    fortune
    darktable
    ansel
    rawtherapee
    gimp
    telegram-desktop
    qbittorrent
    calibre
    quassel
    obsidian
    freetube
    youtube-tui
    networkmanagerapplet
    shellcheck
    swww
    zathura
    sxiv
    jhead
    ranger
    digikam
    jq
    nvd
    wlogout
    filezilla
    vlc
    easyeffects
    protonmail-desktop
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
      flavour = ["mocha"];
      accents = ["lavender"];
    })
    font-awesome
    fira-sans
    powerline-fonts
    powerline-symbols
    nerd-fonts.fantasque-sans-mono
    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';

    ".config/wireplumber/bluetooth.lua.d/51-bluez-config.lua".text = ''
      bluez_monitor.properties = {
      	["bluez5.enable-sbc-xq"] = true,
      	["bluez5.enable-msbc"] = true,
      	["bluez5.enable-hw-volume"] = true,
      	["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
      }
    '';
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;

    initContent = ''
      # This command lets me execute arbitrary binaries downloaded through channels such as mason.
      export NIX_LD=$(nix eval --impure --raw --expr 'let pkgs = import <nixpkgs> {}; NIX_LD = pkgs.lib.fileContents "${pkgs.stdenv.cc}/nix-support/dynamic-linker"; in NIX_LD')
    '';
  };

  programs.starship = {
    enable = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.git = {
    enable = true;
    userName = "Bruno Sabença";
    userEmail = "bruno@brunosabenca.com";
    delta.enable = true;
    extraConfig = {
      format = {
        pretty = "oneline";
      };
      log = {
        decorate = "short";
        abbrevCommit = true;
      };
    };
  };

  programs.kitty = {
    enable = true;
    settings = {
      font = "FatasqueSansM Nerd Font";
      font_size = "14";
    };
  };

  catppuccin.mpv.enable = false;

  programs.mpv = {
    enable = true;
    package = (
      pkgs.mpv-unwrapped.wrapper {
        scripts = with pkgs.mpvScripts; [
          uosc
          sponsorblock
        ];

        mpv = pkgs.mpv-unwrapped.override {
          waylandSupport = true;
        };
      }
    );
    config = {
      hwdec = "auto-safe";
      vo = "gpu";
      profile = "gpu-hq";
      gpu-context = "wayland";
      force-window = "immediate";
      interpolation = true;
      tscale = "oversample";
      video-sync = "display-resample";
      sub-font = lib.mkForce "Gandhi Sans Bold";
      sub-border-size = 1;
      sub-color = "#CDCDCD";
      # sub-shadow = 3;
      sub-shadow-color = "#000000";
      sub-shadow-offset = 2;
    };
  };

  stylix.targets = {
    vim.enable = false;
    neovim.enable = false;
  };

  programs.vscode = {
    enable = true;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      vscodevim.vim
      catppuccin.catppuccin-vsc-icons
      jnoortheen.nix-ide
      kamadorueda.alejandra
      timonwong.shellcheck
    ];

    profiles.default.userSettings = {
      "workbench.startupEditor" = "none";
      "workbench.iconTheme" = "catppuccin-mocha";
      "window.titleBarStyle" = "custom";
      "window.zoomLevel" = 1;
      "keyboard.dispatch" = "keyCode";
      "editor.minimap.renderCharacters" = false;
      "editor.minimap.scale" = 2;
      "editor.minimap.size" = "fill";
      "vim.easymotion" = true;
      "vim.incsearch" = true;
      "vim.useSystemClipboard" = true;
      "vim.hlsearch" = true;
      "vim.leader" = "<space>";
      "vim.handleKeys" = {
        "<C-p>" = false;
        "<C-f>" = false;
      };
      "extensions.experimental.affinity" = {
        "vscodevim.vim" = 1;
      };
    };
  };

  xdg.configFile."mimeapps.list".force = true;
  xdg.mimeApps = {
    enable = true;
    # Useful commands for debugging:
    # XDG_UTILS_DEBUG_LEVEL=2 xdg-mime query filetype example.png
    # XDG_UTILS_DEBUG_LEVEL=2 xdg-mime query default image/png
    defaultApplications = {
      # "text/plain" = ["neovide.desktop"];
      "application/pdf" = ["zathura.desktop"];
      "image/jpeg" = ["okular.desktop"];
      "image/png" = ["okular.desktop"];
      "image/*" = ["okular.desktop"];
      "video/png" = ["mpv.desktop"];
      "video/jpg" = ["mpv.desktop"];
      "video/*" = ["mpv.desktop"];
      "text/html" = ["firefox.desktop"];
      "x-scheme-handler/http" = ["firefox.desktop"];
      "x-scheme-handler/https" = ["firefox.desktop"];
      "x-scheme-handler/about" = ["firefox.desktop"];
      "x-scheme-handler/unknown" = ["firefox.desktop"];
    };
    associations.added = {};
  };
}
