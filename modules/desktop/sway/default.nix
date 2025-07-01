{
  pkgs,
  lib,
  config,
  username,
  ...
}: let
  # bash script to let dbus know about important env variables and
  # propagate them to relevant services run at the end of sway config
  # see
  # https://github.com/emersion/xdg-desktop-portal-wlr/wiki/"It-doesn't-work"-Troubleshooting-Checklist
  # note: this is pretty much the same as  /etc/sway/config.d/nixos.conf but also restarts
  # some user services to make sure they have the correct environment variables
  dbus-sway-environment = pkgs.writeTextFile {
    name = "dbus-sway-environment";
    destination = "/bin/dbus-sway-environment";
    executable = true;

    text = ''
      dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
      systemctl --user stop pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
      systemctl --user start pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
    '';
  };

  sway-launch-or-focus = pkgs.writeShellScriptBin "sway-launch-or-focus" ''
    #!/bin/bash

    # Input parameters
    WORKSPACE="$1"
    APP_IDENTIFIER="$2"
    APP_COMMAND="$3"

    if [ -z "$WORKSPACE" ] || [ -z "$APP_IDENTIFIER" ] || [ -z "$APP_COMMAND" ]; then
      echo "Usage: $0 <workspace> <app_identifier> <app_command>"
      exit 1
    fi

    # Check if the application is in any workspace's representation
    FOUND_WORKSPACE=$(swaymsg -t get_workspaces | jq -r \
        '.[] | select(.name == "'"$WORKSPACE"'") | select(.representation | test("'"$APP_IDENTIFIER"'")) | .name')

    if [ -n "$FOUND_WORKSPACE" ]; then
        # echo Application is found, focus the workspace
        swaymsg workspace "$WORKSPACE"
    else
        # echo Application not found, launch it in the specified workspace
        swaymsg workspace "$WORKSPACE"
        exec $APP_COMMAND &
    fi
  '';
in {
  imports = [
    ../components/waybar
    ../components/mako
    ../components/wofi
  ];

  environment.systemPackages = with pkgs;
    [
      dbus-sway-environment
      sway-launch-or-focus
      wev # wayland event viewer (find out key names)
      notify-desktop # provides the notify-send binary to trigger mako
      grim # screenshot functionality
      slurp # screenshot functionality
      wl-clipboard-rs # wl-copy and wl-paste for copy/paste from stdin / stdout
      xclip # TODO: figure out why I still need this
      swaylock-fancy # Fancy lock screen
      libinput # Handles input devices in Wayland compositors
      libinput-gestures # Gesture mapper for libinput
      brightnessctl # CLI to control brightness
      networkmanager # Manage wireless networks
      pulsemixer # CLI to control puleaudio
      alsa-utils # for amixer to mute mic
      wdisplays # xrandr type gui to mess with monitor placement
      wl-mirror # simple wayland display mirror program
    ]
    # Add some KDE packages I have become used to
    ++ (with kdePackages; [
      konsole
      ark
      dolphin
      dolphin-plugins
      gwenview
      kdegraphics-thumbnailers
      kfilemetadata
      kimageformats
      qtimageformats
      kio
      kio-admin
      kio-extras
      kio-fuse
      kservice
      libheif
      okular
      polkit-kde-agent-1
      # plasma-workspace
      qtwayland
      kdialog
    ]);

  # Enable the gnome-keyring secrets vault.
  # Will be exposed through DBus to programs willing to store secrets.
  services.gnome.gnome-keyring.enable = true;

  # enable Sway window manager
  programs.sway = {
    enable = true;

    package = pkgs.sway;

    wrapperFeatures.gtk = true;
    xwayland.enable = true;

    # clear out default packages
    extraPackages = [];

    extraSessionCommands = ''
      export SDL_VIDEODRIVER=wayland
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
      export _JAVA_AWT_WM_NONREPARENTING=1
      export MOZ_ENABLE_WAYLAND=1
      export XDG_SESSION_TYPE=wayland
      export XDG_SESSION_DESKTOP=KDE
      export XDG_CURRENT_DESKTOP=KDE
      export XDG_DESKTOP_PORTAL_PREFFERED=kde
    '';
  };

  services.libinput.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # Automount sd cards
  services.udisks2.enable = true;

  # Set up upower to be able to get battery levels of connected devices.
  services.upower.enable = true;

  # Filesystem interface implemented by local/remote fileSystems: Mount, trash, and other functionalities for file explorer
  services.gvfs.enable = true;

  # network manager
  networking.networkmanager.enable = true;

  # bluetooth manager
  services.blueman.enable = true;

  home-manager.users.${username} = {
    config,
    pkgs,
    ...
  }: {
    # Configure cursor
    wayland.windowManager.sway = {
      config = {
        seat = {
          "*" = {
            xcursor_theme = "${config.gtk.cursorTheme.name} ${toString config.gtk.cursorTheme.size}";
          };
        };
      };
    };

    home.pointerCursor = {
      name = "Banana";
      size = 32;
      package = pkgs.banana-cursor;
      x11.enable = true;
      gtk.enable = true;
    };

    gtk = {
      enable = true;
      cursorTheme = {
        name = "Banana";
        size = 32;
        package = pkgs.banana-cursor;
      };
    };

    # Services required for a smooth sway/waybar experience
    services.batsignal.enable = true;

    # Automount sd/usb
    services.udiskie.enable = true;

    # Enable the playerctld to be able to control music players and mpris-proxy to proxy bluetooth devices.
    services.playerctld.enable = true;
    services.mpris-proxy.enable = true;

    home.packages = [pkgs.dconf];
    dconf.settings."org/blueman/plugins/powermanager".auto-power-on = false;

    # stylix.targets.kde.enable = false;

    # symlink to sway config file in dotfiles repo
    xdg.configFile = {
      "sway/config" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/git/nix/dotfiles/.config/sway/config";
      };
      "sway/run-or-raise" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/git/nix/dotfiles/.config/sway/run-or-raise";
      };
    };
  };
}
