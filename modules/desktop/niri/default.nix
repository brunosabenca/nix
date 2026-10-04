{
  pkgs,
  username,
  lib,
  inputs,
  ...
}:
{
  imports = [
    ../common
    inputs.noctalia.nixosModules.default
    inputs.noctalia-greeter.nixosModules.default
  ];

  environment.systemPackages = with pkgs; [
    wev # wayland event viewer (find out key names)
    notify-desktop # provides the notify-send binary to trigger mako
    libinput # Handles input devices in Wayland compositors
    libinput-gestures # Gesture mapper for libinput
    networkmanager # Manage wireless networks
    pulsemixer # CLI to control puleaudio
    alsa-utils # for amixer to mute mic
    wdisplays # xrandr type gui to mess with monitor placement
    wl-mirror # simple wayland display mirror program
    nautilus
    xwayland-satellite # xwayland support
  ];

  programs.niri.enable = true;

  services.upower.enable = true;

  programs.noctalia = {
    enable = true;
    systemd.enable = true;
  };

  services.displayManager.noctalia-greeter = {
    enable = true;
    greeter-args = "--session niri";
  };

  # The greeter's compositor needs the GPU card node (video) and the render
  # node (render) to create its EGL/Vulkan renderer.
  users.users.greeter.extraGroups = [
    "video"
    "render"
  ];

  home-manager.users.${username} =
    {
      pkgs,
      ...
    }:
    {
      imports = [ inputs.noctalia.homeModules.default ];

      programs.noctalia = {
        enable = true;
        settings.theme.templates = {
          # Generates ~/.config/kitty/themes/noctalia.conf and live-reloads kitty
          builtin_ids = [ "kitty" ];
          community_ids = [
            # Rewrites [theme.custom] in ~/.config/herdr/config.toml (must stay unmanaged by Nix)
            "herdr"
            # Generates ~/.claude/themes/noctalia.json; select "Noctalia" via /theme
            "claude-code"
          ];
          # Generates ~/.config/zathura/noctalia, included from zathurarc (read on zathura startup)
          user.zathura = {
            input_path = "$XDG_CONFIG_HOME/noctalia/templates/zathura";
            output_path = "$XDG_CONFIG_HOME/zathura/noctalia";
          };
        };
      };

      xdg.configFile."noctalia/templates/zathura".source = ./zathura-theme;

      programs.fuzzel = {
        enable = true;
        settings = {
          main = {
            font = lib.mkForce "JetBrains Mono:size=23";
            horizontal-pad = 20;
            lines = 8;
            exit-on-keyboard-focus-loss = true;
            terminal = "kitty";
          };
          border = {
            width = 4;
            radius = 8;
          };
          colours = {
            background = "1e1e2ef7";
            text = "cdd6f4ff";
            match = "cba6f7ff";
            selection = "585b70ff";
            selection-text = "cdd6f4ff";
            selection-match = "cba6f7ff";
            border = "cba6f7ff";
          };
        };
      };

      xdg.configFile."niri/config.kdl".source = ./config.kdl;
    };
}
