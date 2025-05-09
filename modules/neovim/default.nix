{
  inputs,
  config,
  pkgs,
  home-manager,
  neovim-nightly-overlay,
  system,
  username,
  ...
}: {
  environment.systemPackages = [
    inputs.neovim-nightly-overlay.packages.${pkgs.system}.default
  ];

  home-manager.users.${username} = let
    nvimMimeTypes = [
      "text/markdown"
      "text/plain"
      "text/x-c++src"
      "text/x-chdr"
      "text/x-csrc"
      "text/x-makefile"
      "text/x-markdown"
      "text/x-nix"
      "text/x-python"
      "text/x-rust"
      "text/x-sh"
    ];
  in
    {
      config,
      pkgs,
      ...
    }: {
      home.sessionVariables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
      };

      home.shellAliases = {
        vi = "nvim";
        vim = "nvim";
        vimdiff = "nvim -d";
      };

      xdg.desktopEntries."nvim" = {
        name = "nvim";
        comment = "Edit text files";
        icon = "nvim";
        exec = "${pkgs.kitty}/bin/kitty -e ${pkgs.zsh}/bin/zsh -l -c \"${inputs.neovim-nightly-overlay.packages.${pkgs.system}.default}/bin/nvim %F\"";
        categories = ["Development" "Utility" "TextEditor"];
        terminal = false;
        mimeType = nvimMimeTypes;
      };

      xdg.mimeApps = {
        enable = true;

        defaultApplications = builtins.listToAttrs (map
          (mimeType: {
            name = mimeType;
            value = ["nvim.desktop"];
          })
          nvimMimeTypes);

        associations.added = {
          "text/x-nix" = ["nvim.desktop"];
        };
      };

      xdg.configFile = {
        "nvim/lazyvim.json" = {source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/git/lazyvim/lazyvim.json";};
        "nvim/neoconf.json" = {source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/git/lazyvim/neoconf.json";};
        "nvim/init.lua" = {source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/git/lazyvim/init.lua";};
        "nvim/lazy-lock.json" = {source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/git/lazyvim/lazy-lock.json";};
        "nvim/stylua.toml" = {source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/git/lazyvim/.stylua.toml";};
        "nvim/lua" = {source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/git/lazyvim/lua";};
      };
    };
}
