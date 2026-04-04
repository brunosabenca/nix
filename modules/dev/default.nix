{
  pkgs,
  inputs,
  system,
  ...
}:
{
  imports = [
    ./lua
  ];

  environment.systemPackages = with pkgs; [
    opencode
    (pkgs.runCommand "claude" { } ''
      mkdir -p $out/bin
      ln -s ${inputs.claude-code.packages.${system}.claude-code-bun}/bin/claude-bun $out/bin/claude
    '')
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
    nodejs_22
    git-open
    codespell
    prettierd
    sshfs
bash-language-server
  ];
}
