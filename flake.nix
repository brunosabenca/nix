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

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
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

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
    };

    nil-lsp = {
      url = "github:oxalica/nil";
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
  };

  outputs =
    {
      self,
      nixpkgs,
      stylix,
      lanzaboote,
      kmonad,
      ...
    }@inputs:
    let
      supportedSystems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
      username = "bruno";
      inherit (self) outputs;
    in
    {
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-tree;

      nixosConfigurations = {
        monolith =
          let
            system = "x86_64-linux";
            hostname = "monolith";
          in
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
              ./hosts/monolith
              ./modules/desktop/kde-wayland
              ./modules/desktop/niri
              ./modules/core
              ./modules/dev
              ./modules/neovim
              ./modules/vscode
              ./modules/home
              stylix.nixosModules.stylix
              lanzaboote.nixosModules.lanzaboote
              (
                { pkgs, lib, ... }:
                {

                  environment.systemPackages = [
                    # For debugging and troubleshooting Secure Boot.
                    pkgs.sbctl
                  ];

                  # Lanzaboote currently replaces the systemd-boot module.
                  # This setting is usually set to true in configuration.nix
                  # generated at installation time. So we force it to false
                  # for now.
                  boot.loader.systemd-boot.enable = lib.mkForce false;

                  boot.lanzaboote = {
                    enable = true;
                    pkiBundle = "/var/lib/sbctl";
                  };
                }
              )
            ];
          };

        fourforty =
          let
            system = "x86_64-linux";
            hostname = "fourforty";
          in
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
              ./hosts/fourforty
              ./modules/desktop/kde-wayland
              ./modules/core
              ./modules/dev
              ./modules/neovim
              ./modules/home
              stylix.nixosModules.stylix
              kmonad.nixosModules.default
            ];
          };

        cave =
          let
            system = "x86_64-linux";
            hostname = "cave";
          in
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
              ./hosts/cave
              ./modules/nixos/qbittorrent-service
              ./modules/core/terminal
              ./modules/core/git
              ./modules/core/man
              ./modules/core/man
              ./modules/cloudflared
              ./modules/navidrome
              stylix.nixosModules.stylix
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
