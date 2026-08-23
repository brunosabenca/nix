{
  pkgs,
  username,
  ...
}:
{
  imports = [
    ./man
    ./nix
    ./git
    ./terminal
    ./locale
    ./users
  ];

  programs.zsh.enable = true;
  programs.fish.enable = true;
}
