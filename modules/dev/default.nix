{
  pkgs,
  ...
}:
{
  imports = [
    ./lua
  ];

  environment.systemPackages = with pkgs; [
    nil # Nix language server
    lua
    gcc
    gdb
    cmake
    gnumake
    python3
    ruby
    go # Go
    gopls # Go language server
    nodejs_20
    git-open
    codespell
    prettierd
    sshfs
    nodePackages_latest.prettier
    bash-language-server
  ];
}
