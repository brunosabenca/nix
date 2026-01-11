{
  pkgs,
  lib,
  username,
  ...
}:
{
  home-manager.users.${username} = {
    programs.zsh = {
      enable = true;
      autosuggestion.enable = true;
      enableCompletion = true;

      initContent = ''
        # This command lets me execute arbitrary binaries downloaded through channels such as mason.
        export NIX_LD=$(nix eval --impure --raw --expr 'let pkgs = import <nixpkgs> {}; NIX_LD = pkgs.lib.fileContents "${pkgs.stdenv.cc}/nix-support/dynamic-linker"; in NIX_LD')
      '';
    };

    programs.fish = {
      enable = true;
    };

    programs.starship.enable = true;

    programs.fzf = {
      enable = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
    };

    programs.zellij = {
      enable = true;
      enableFishIntegration = false;
      enableZshIntegration = false;
    };

    programs.kitty = lib.mkForce {
      enable = true;
      shellIntegration.enableFishIntegration = true;
      settings = {
        confirm_os_window_close = 0;
        dynamic_background_opacity = true;
        enable_audio_bell = false;
        mouse_hide_wait = "-1.0";
        window_padding_width = 10;
        background_opacity = "0.5";
        background_blur = 5;
      };
    };
    stylix.targets.kitty.enable = true;
  };
}
