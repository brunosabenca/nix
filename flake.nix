{
  description = "Bruno's NixOS system configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
      # don't download darwin deps
      inputs.darwin.follows = "";
    };

    dotfiles = {
      url = "github:brunosabenca/dotfiles";
      flake = false;
    };

    catppuccin.url = "github:catppuccin/nix";

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim = {
      url = "github:brunosabenca/nixCats-nvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.3";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    kmonad = {
      url = "github:kmonad/kmonad?dir=nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    copyparty.url = "github:9001/copyparty";

    claude-code.url = "github:sadjow/claude-code-nix";

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      stylix,
      lanzaboote,
      kmonad,
      copyparty,
      nur,
      ...
    }@inputs:
    let
      forAllSystems = with nixpkgs; (lib.genAttrs lib.systems.flakeExposed);
      username = "bruno";
      inherit (self) outputs;

      mkHost =
        {
          hostname,
          system ? "x86_64-linux",
          extraModules ? [ ],
        }:
        nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit
              system
              hostname
              username
              inputs
              ;
          }
          // inputs;

          modules = [
            ./.
            ./hosts/${hostname}
            stylix.nixosModules.stylix
            nur.modules.nixos.default
          ]
          ++ extraModules;
        };
    in
    {
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-tree;

      nixosConfigurations = {
        monolith = mkHost {
          hostname = "monolith";
          extraModules = [
            ./modules/desktop/niri
            ./modules/core
            ./modules/dev
            ./modules/vscode
            ./modules/home
            ./modules/firefox
            ./modules/neovim
            lanzaboote.nixosModules.lanzaboote
            (
              {
                pkgs,
                lib,
                ...
              }:
              {
                environment.systemPackages = [
                  pkgs.sbctl
                ];

                boot.loader.systemd-boot.enable = lib.mkForce false;

                boot.lanzaboote = {
                  enable = true;
                  pkiBundle = "/var/lib/sbctl";
                };
              }
            )
          ];
        };

        fourforty = mkHost {
          hostname = "fourforty";
          extraModules = [
            ./modules/desktop/niri
            ./modules/core
            ./modules/dev
            ./modules/home
            ./modules/neovim
            ./modules/firefox
            kmonad.nixosModules.default
          ];
        };

        firefly = mkHost {
          hostname = "firefly";
          extraModules = [
            ./modules/desktop/niri
            ./modules/core
            ./modules/dev
            ./modules/home
            ./modules/firefox
            ./modules/neovim
            kmonad.nixosModules.default
          ];
        };

        cave = mkHost {
          hostname = "cave";
          extraModules = [
            ./modules/nixos/qbittorrent-service
            ./modules/core/terminal
            ./modules/core/git
            ./modules/core/man
            ./modules/cloudflared
            ./modules/navidrome
            copyparty.nixosModules.default
            ./modules/copyparty
          ];
        };
      };
    };

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
}
