{
  pkgs,
  lib,
  username,
  ...
}:
{
  home-manager.users.${username} = {
    xdg.enable = true;

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
      shellAbbrs = {
        "--help" = "--help | bat -plhelp";
        "-h" = "-h | bat -plhelp";
      };
      functions = {
        fdp = "fd --type file --type symlink $argv -X bat";
        starship_transient_prompt_func = "starship module character";
      };
      plugins = [
        {
          name = "fzf-fish";
          src = pkgs.fishPlugins.fzf-fish.src;
        }
      ];
      interactiveShellInit = ''
        set fish_greeting # Disable greeting
        enable_transience
      '';
    };

    programs.zoxide = {
      enable = true;
      enableFishIntegration = true;
    };

    programs.starship.enable = true;

    programs.fzf = {
      enable = true;
      enableFishIntegration = false; # fzf-fish plugin handles this
      enableZshIntegration = true;
      enableBashIntegration = true;
    };

    programs.zellij = {
      enable = true;
    };

    programs.kitty = {
      enable = true;
      shellIntegration = {
        enableFishIntegration = true;
        enableZshIntegration = true;
        enableBashIntegration = true;
      };
      settings = {
        shell = "fish";
        confirm_os_window_close = 0;
        dynamic_background_opacity = true;
        enable_audio_bell = false;
        mouse_hide_wait = "-1.0";
        window_padding_width = 10;
        background_opacity = "0.9";
        background_blur = 5;
        cursor_trail = 1;
        allow_remote_control = "yes";
        listen_on = "unix:/tmp/kitty";
        font_size = 14;
        font_family = "JetBrainsMono Nerd Font";
        bold_font = "auto";
        italic_font = "auto";
        bold_italic_font = "auto";

      };
      extraConfig = ''
        include dank-tabs.conf
        include dank-theme.conf
        map ctrl+shift+t new_tab_with_cwd

        # kitty-scrollback.nvim Kitten alias
        action_alias kitty_scrollback_nvim kitten '${pkgs.vimPlugins.kitty-scrollback-nvim}/python/kitty_scrollback_nvim.py'
        # Browse scrollback buffer in nvim
        map kitty_mod+h kitty_scrollback_nvim
        # Browse output of the last shell command in nvim
        map kitty_mod+g kitty_scrollback_nvim --config ksb_builtin_last_cmd_output
        # Show clicked command output in nvim
        mouse_map ctrl+shift+right press ungrabbed combine : mouse_select_command_output : kitty_scrollback_nvim --config ksb_builtin_last_visited_cmd_output
      '';
    };
    stylix.targets.kitty.enable = false;

    programs.yazi = {
      enable = true;
      shellWrapperName = "y";
      enableFishIntegration = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
    };
    stylix.targets.yazi.enable = true;

  };
}
