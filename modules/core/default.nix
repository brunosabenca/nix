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
    ./locale
    ./users
  ];

  programs.zsh.enable = true;
  programs.fish.enable = true;
}
