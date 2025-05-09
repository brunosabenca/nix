{
  inputs,
  home-manager,
  pkgs,
  username,
  ...
}: {
  # Required for nix flakes
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}
