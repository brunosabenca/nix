{
  inputs,
  pkgs,
  lib,
  username,
  ...
}:
{
  environment.systemPackages = [
    inputs.neovim-nightly-overlay.packages.${pkgs.system}.default
  ];

  home-manager.users.${username} =
    let
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
    }:
    with lib;
    let
      build-dependent-pkgs = with pkgs; [
        acl
        attr
        bzip2
        curl
        libsodium
        libssh
        libxml2
        openssl
        stdenv.cc.cc
        systemd
        util-linux
        xz
        zlib
        zstd
        glib
        libcxx
      ];

      makePkgConfigPath = x: makeSearchPathOutput "dev" "lib/pkgconfig" x;
      makeIncludePath = x: makeSearchPathOutput "dev" "include" x;

      nvim-depends-library = pkgs.buildEnv {
        name = "nvim-depends-library";
        paths = map lib.getLib build-dependent-pkgs;
        extraPrefix = "/lib/nvim-depends";
        pathsToLink = [ "/lib" ];
        ignoreCollisions = true;
      };
      nvim-depends-include = pkgs.buildEnv {
        name = "nvim-depends-include";
        paths = splitString ":" (makeIncludePath build-dependent-pkgs);
        extraPrefix = "/lib/nvim-depends/include";
        ignoreCollisions = true;
      };
      nvim-depends-pkgconfig = pkgs.buildEnv {
        name = "nvim-depends-pkgconfig";
        paths = splitString ":" (makePkgConfigPath build-dependent-pkgs);
        extraPrefix = "/lib/nvim-depends/pkgconfig";
        ignoreCollisions = true;
      };
      buildEnv = [
        "CPATH=${config.home.profileDirectory}/lib/nvim-depends/include"
        "CPLUS_INCLUDE_PATH=${config.home.profileDirectory}/lib/nvim-depends/include/c++/v1"
        "LD_LIBRARY_PATH=${config.home.profileDirectory}/lib/nvim-depends/lib"
        "LIBRARY_PATH=${config.home.profileDirectory}/lib/nvim-depends/lib"
        "NIX_LD_LIBRARY_PATH=${config.home.profileDirectory}/lib/nvim-depends/lib"
        "PKG_CONFIG_PATH=${config.home.profileDirectory}/lib/nvim-depends/pkgconfig"
      ];
    in
    {
      home.packages = with pkgs; [
        patchelf
        nvim-depends-include
        nvim-depends-library
        nvim-depends-pkgconfig
        ripgrep
      ];
      home.extraOutputsToInstall = [ "nvim-depends" ];
      home.shellAliases.nvim =
        (concatStringsSep " " buildEnv)
        + " SQLITE_CLIB_PATH=${pkgs.sqlite.out}/lib/libsqlite3.so "
        + "nvim";

      programs.neovim = {
        enable = true;

        withNodeJs = true;
        withPython3 = true;
        withRuby = true;

        extraPackages = with pkgs; [
          doq
          sqlite
          cargo
          clang
          cmake
          gcc
          gnumake
          ninja
          pkg-config
          yarn
        ];

        extraLuaPackages = ls: with ls; [ luarocks ];
      };

      stylix.targets = {
        vim.enable = false;
        neovim.enable = false;
      };

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
        exec = "${pkgs.wezterm}/bin/ghostty -e ${pkgs.zsh}/bin/zsh -l -c \"${
          inputs.neovim-nightly-overlay.packages.${pkgs.system}.default
        }/bin/nvim %F\"";
        categories = [
          "Development"
          "Utility"
          "TextEditor"
        ];
        terminal = false;
        mimeType = nvimMimeTypes;
      };

      xdg.mimeApps = {
        enable = true;

        defaultApplications = builtins.listToAttrs (
          map (mimeType: {
            name = mimeType;
            value = [ "nvim.desktop" ];
          }) nvimMimeTypes
        );

        associations.added = {
          "text/x-nix" = [ "nvim.desktop" ];
        };
      };

      xdg.configFile = {
        "nvim/lazyvim.json" = {
          source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/git/lazyvim/lazyvim.json";
        };
        "nvim/neoconf.json" = {
          source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/git/lazyvim/neoconf.json";
        };
        "nvim/init.lua" = {
          source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/git/lazyvim/init.lua";
        };
        "nvim/lazy-lock.json" = {
          source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/git/lazyvim/lazy-lock.json";
        };
        "nvim/stylua.toml" = {
          source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/git/lazyvim/.stylua.toml";
        };
        "nvim/lua" = {
          source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/git/lazyvim/lua";
        };
      };
    };
}
