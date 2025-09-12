{
  inputs,
  pkgs,
  lib,
  config,
  username,
  ...
}:
{
  # enable OpenGL
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  services.desktopManager.plasma6.enable = true;

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  # Set plasma6 as default session
  services.displayManager.defaultSession = "plasma";

  # KDE system packages
  environment.systemPackages = with pkgs; [
    kdePackages.kcalc
    kdePackages.kleopatra
    kdePackages.spectacle
    kdePackages.gwenview
    kdePackages.dolphin
    kdePackages.okular
    kdePackages.qtstyleplugin-kvantum
    libnotify
    xclip
    wl-clipboard-rs
  ];

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    # konsole
  ];

  programs.kdeconnect.enable = true;
  environment.sessionVariables = {
    QT_QPA_PLATFORM = "wayland";
  };

  networking.firewall = {
    enable = true;
    allowedTCPPortRanges = [
      {
        from = 1714;
        to = 1764;
      } # KDE Connect
    ];
    allowedUDPPortRanges = [
      {
        from = 1714;
        to = 1764;
      } # KDE Connect
    ];
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  home-manager.users.${username} = {
    stylix.targets.kde.enable = true;

    programs.plasma = {
      enable = true;
      panels = [
        {
          location = "bottom";
          hiding = "windowscover";
          widgets = [
            {
              kickoff = {
                sortAlphabetically = true;
                icon = "nix-snowflake-white";
              };
            }
            {
              iconTasks = {
                launchers = [
                  "applications:systemsettings.desktop"
                  "applications:org.wezfurlong.wezterm.desktop"
                  "applications:org.kde.dolphin.desktop"
                  "applications:firefox.desktop"
                  "applications:obsidian.desktop"
                  "applications:neovide.desktop"
                  "applications:sublime_merge.desktop"
                ];
              };
            }
            "org.kde.plasma.marginsseparator"
            {
              digitalClock = {
                calendar.firstDayOfWeek = "monday";
                time.format = "24h";
              };
            }
            {
              systemTray.items = {
                # We explicitly show bluetooth and battery
                shown = [
                  "org.kde.plasma.battery"
                  "org.kde.plasma.bluetooth"
                  "org.kde.plasma.networkmanagement"
                  "org.kde.plasma.volume"
                ];
                # And explicitly hide networkmanagement and volume
                hidden = [
                ];
              };
            }
          ];
        }
      ];
      shortcuts = {
        kaccess = {
          "Toggle Screen Reader On and Off" = [
            "Meta+Alt+Ctrl+Esc"
          ];
        };
        ksmserver = {
          "Lock Session" = [
            "Meta+Alt+Ctrl+Esc"
          ];
        };
        kwin = {
          "Window Maximize" = [
            "Meta+F"
          ];
          "Window Close" = [
            "Meta+Q"
          ];
        };
        plasmashell = {
          "activate task manager entry 1" = "Meta+1,Meta+1,Activate Task Manager Entry 1";
          "activate task manager entry 10" = ",,Activate Task Manager Entry 10";
          "activate task manager entry 2" = "Meta+T\tMeta+2,Meta+2,Activate Task Manager Entry 2";
          "activate task manager entry 3" = "Meta+R\tMeta+3,Meta+3,Activate Task Manager Entry 3";
          "activate task manager entry 4" = "Meta+W\tMeta+4,Meta+4,Activate Task Manager Entry 4";
          "activate task manager entry 5" = "Meta+Z\tMeta+Z,Meta+5,Activate Task Manager Entry 5";
          "activate task manager entry 6" = "Meta+V\tMeta+V,Meta+6,Activate Task Manager Entry 6";
          "activate task manager entry 7" = "Meta+G\tMeta+7,Meta+7,Activate Task Manager Entry 7";
          "activate task manager entry 8" = "Meta+8,Meta+8,Activate Task Manager Entry 8";
          "activate task manager entry 9" = "Meta+9,Meta+9,Activate Task Manager Entry 9";
        };
      };
      configFile = {
        #"dolphinrc"."DetailsMode"."PreviewSize" = 160;
        #"dolphinrc"."ExtractDialog"."2560x1440 screen: Height" = 720;
        #"dolphinrc"."ExtractDialog"."2560x1440 screen: Width" = 1651;
        #"dolphinrc"."General"."OpenExternallyCalledFolderInNewTab" = true;
        #"dolphinrc"."General"."ViewPropsTimestamp" = "2023,11,22,18,46,31.83";
        #"dolphinrc"."IconsMode"."PreviewSize" = 256;
        #"dolphinrc"."KFileDialog Settings"."Places Icons Auto-resize" = false;
        #"dolphinrc"."KFileDialog Settings"."Places Icons Static Size" = 32;
        #"dolphinrc"."PlacesPanel"."IconSize" = 32;
        #"kcminputrc"."Libinput/1149/8257/Kensington Slimblade Trackball"."LeftHanded" = true;
        #"kcminputrc"."Libinput/1149/8257/Kensington Slimblade Trackball"."PointerAcceleration" = 0.000;
        #"kcminputrc"."Libinput/5426/138/Razer Razer Viper Mini"."PointerAccelerationProfile" = 2;
        #"kcminputrc"."Mouse"."X11LibInputXAccelProfileFlat" = true;
        #"kcminputrc"."Mouse"."XLbInptAccelProfileFlat" = true;
        #"kcminputrc"."Mouse"."XLbInptLeftHanded" = false;
        #"kcminputrc"."Mouse"."XLbInptNaturalScroll" = false;
        #"kcminputrc"."Mouse"."XLbInptPointerAcceleration" = 0.2;
        #"kcminputrc"."Mouse"."cursorTheme" = "Bibata-Original-Classic";
        #"kded5rc"."Module-browserintegrationreminder"."autoload" = false;
        #"kded5rc"."Module-device_automounter"."autoload" = true;
        #"kdeglobals"."KDE"."SingleClick" = false;
        #"kdeglobals"."KFileDialog Settings"."Allow Expansion" = false;
        #"kdeglobals"."KFileDialog Settings"."Automatically select filename extension" = true;
        #"kdeglobals"."KFileDialog Settings"."Breadcrumb Navigation" = true;
        #"kdeglobals"."KFileDialog Settings"."Decoration position" = 0;
        #"kdeglobals"."KFileDialog Settings"."LocationCombo Completionmode" = 5;
        #"kdeglobals"."KFileDialog Settings"."PathCombo Completionmode" = 5;
        #"kdeglobals"."KFileDialog Settings"."Show Bookmarks" = false;
        #"kdeglobals"."KFileDialog Settings"."Show Full Path" = false;
        #"kdeglobals"."KFileDialog Settings"."Show Inline Previews" = true;
        #"kdeglobals"."KFileDialog Settings"."Show Preview" = false;
        #"kdeglobals"."KFileDialog Settings"."Show Speedbar" = true;
        #"kdeglobals"."KFileDialog Settings"."Show hidden files" = true;
        #"kdeglobals"."KFileDialog Settings"."Sort by" = "Date";
        #"kdeglobals"."KFileDialog Settings"."Sort directories first" = true;
        #"kdeglobals"."KFileDialog Settings"."Sort hidden files last" = false;
        #"kdeglobals"."KFileDialog Settings"."Sort reversed" = true;
        #"kdeglobals"."KFileDialog Settings"."Speedbar Width" = 152;
        #"kdeglobals"."KFileDialog Settings"."View Style" = "Simple";
        #"kdeglobals"."PreviewSettings"."MaximumRemoteSize" = 0;
        #"kdeglobals"."WM"."activeBackground" = "30,30,46";
        #"kdeglobals"."WM"."activeBlend" = "249,226,175";
        #"kdeglobals"."WM"."activeForeground" = "205,214,244";
        #"kdeglobals"."WM"."inactiveBackground" = "30,30,46";
        #"kdeglobals"."WM"."inactiveBlend" = "69,71,90";
        #"kdeglobals"."WM"."inactiveForeground" = "205,214,244";
        #"kiorc"."Confirmations"."ConfirmDelete" = false;
        #"kiorc"."Confirmations"."ConfirmEmptyTrash" = true;
        #"kiorc"."Confirmations"."ConfirmTrash" = false;
        #"kiorc"."Executable scripts"."behaviourOnLaunch" = "execute";
        #"kscreenlockerrc"."Daemon"."Timeout" = 30;
        #"ksmserverrc"."General"."loginMode" = "emptySession";
        #"kwinrc"."Desktops"."Number" = 1;
        #"kwinrc"."Desktops"."Rows" = 1;
        #"kwinrc"."NightColor"."Active" = true;
        #"kwinrc"."NightColor"."LatitudeAuto" = 51.5145;
        #"kwinrc"."NightColor"."LatitudeFixed" = 52.19;
        #"kwinrc"."NightColor"."LongitudeAuto" = 0.0706;
        #"kwinrc"."NightColor"."LongitudeFixed" = "-0.46";
        #"kwinrc"."NightColor"."Mode" = "Constant";
        #"kwinrc"."Xwayland"."Scale" = 1;
        #"plasma-localerc"."Formats"."LANG" = "en_GB.UTF-8";
        #"spectaclerc"."Annotations"."annotationToolType" = 3;
        #"spectaclerc"."GuiConfig"."captureMode" = 0;
        #"spectaclerc"."ImageSave"."translatedScreenshotsFolder" = "Screenshots";
        #"spectaclerc"."VideoSave"."translatedScreencastsFolder" = "Screencasts";
      };
      dataFile = {
      };
    };
  };
}
