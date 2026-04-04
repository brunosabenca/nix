{
  pkgs,
  inputs,
  system,
  username,
  ...
}:
{
  imports = [
    ./lua
  ];

  home-manager.users.${username} = {
    home.file.".claude/statusline-command.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        # Claude Code status line — mirrors Starship default prompt style
        # Input: JSON via stdin

        input=$(cat)

        cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
        model=$(echo "$input" | jq -r '.model.display_name // ""')
        used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

        # Shorten home directory to ~
        home="$HOME"
        short_cwd="''${cwd/#$home/\~}"

        # Build context usage string (only when data is available)
        ctx_str=""
        if [ -n "$used" ]; then
          used_int=$(printf "%.0f" "$used")
          ctx_str=" ctx:''${used_int}%"
        fi

        # Git branch (skip optional locks)
        branch=""
        if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
          branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null \
            || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
          [ -n "$branch" ] && branch=" ($branch)"
        fi

        printf '\033[1;34m%s\033[0m\033[0;32m%s\033[0m \033[0;36m%s\033[0m%s' \
          "$short_cwd" \
          "$branch" \
          "$model" \
          "$ctx_str"
      '';
    };
  };

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
