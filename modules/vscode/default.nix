{
  inputs,
  pkgs,
  home-manager,
  username,
  ...
}: {
  home-manager.users.${username} = 
    {
      pkgs,
      ...
    }: {
    programs.vscode = {
      enable = true;
      profiles.default.extensions = with pkgs.vscode-extensions; [
        vscodevim.vim
        catppuccin.catppuccin-vsc-icons
        jnoortheen.nix-ide
        kamadorueda.alejandra
        timonwong.shellcheck
      ];

      profiles.default.userSettings = {
        "workbench.startupEditor" = "none";
        "workbench.iconTheme" = "catppuccin-mocha";
        "window.titleBarStyle" = "custom";
        "window.zoomLevel" = 1;
        "keyboard.dispatch" = "keyCode";
        "editor.minimap.renderCharacters" = false;
        "editor.minimap.scale" = 2;
        "editor.minimap.size" = "fill";
        "vim.easymotion" = true;
        "vim.incsearch" = true;
        "vim.useSystemClipboard" = true;
        "vim.hlsearch" = true;
        "vim.leader" = "<space>";
        "vim.handleKeys" = {
          "<C-p>" = false;
          "<C-f>" = false;
        };
        "extensions.experimental.affinity" = {
          "vscodevim.vim" = 1;
        };
      };
    };
  };
}
