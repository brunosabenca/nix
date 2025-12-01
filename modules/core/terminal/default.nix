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

    programs.starship.enable = true;

    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
