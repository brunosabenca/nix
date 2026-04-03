{
  pkgs,
  username,
  ...
}:
{
  imports = [
    ./man
    ./nix
    ./pkgs
    ./git
    ./terminal
    ./mpv
    ./locale
    ./audio
    ./users
  ];

  programs.zsh.enable = true;
  programs.fish.enable = true;
}
