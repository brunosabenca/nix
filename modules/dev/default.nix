{
  config,
  pkgs,
  username,
  ...
}:
{
  imports = [
    ./lua
  ];

  environment.systemPackages = with pkgs; [
    nil # Nix language server
    lua
    gdb
    cmake
    gnumake
    python3
    ruby
    gopls
    nodejs_20
    git-open
    codespell
    prettierd
    sshfs
    nodePackages_latest.prettier
    bash-language-server
  ];
}
