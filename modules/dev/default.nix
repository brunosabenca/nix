{
  config,
  pkgs,
  username,
  ...
}: {
  imports = [
    ./lua
  ];

  environment.systemPackages = with pkgs; [
    lua
    gdb
    cmake
    gnumake
    python3
    ruby
    nodejs_20
    git-open
    codespell
    prettierd
    sshfs
    nodePackages_latest.prettier
    bash-language-server
  ];
}
