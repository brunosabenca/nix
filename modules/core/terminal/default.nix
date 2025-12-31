{
  pkgs,
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

    programs.man.generateCaches = false; # causes slow build times

    programs.starship.enable = true;

    programs.fzf = {
      enable = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
    };

    programs.zellij = {
      enable = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
    };
  };
}
