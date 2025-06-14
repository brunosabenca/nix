{
  description = "Bruno's NixOS system configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    dotfiles = {
      url = "github:brunosabenca/dotfiles";
      flake = false;
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin.url = "github:catppuccin/nix";

    stylix.url = "github:danth/stylix";

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
    };

    nil-lsp = {
      url = "github:oxalica/nil";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    kmonad = {
      url = "github:kmonad/kmonad?dir=nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    stylix,
    lanzaboote,
    kmonad,
    ...
  } @ inputs: let
    supportedSystems = ["x86_64-linux"];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    nixpkgsFor = forAllSystems (system: import nixpkgs {inherit system;});
    username = "bruno";
    inherit (self) outputs;
  in {
    nixosConfigurations = {
      monolith = let
        system = "xf86_64-linux";
        hostname = "monolith";
      in
        nixpkgs.lib.nixosSystem {
          specialArgs = {inherit system hostname username inputs;} // inputs;

          modules = [
            ./.
            ./hosts/monolith
            ./modules/desktop/sway
            ./modules/core
            ./modules/dev
            ./modules/neovim
            stylix.nixosModules.stylix

            lanzaboote.nixosModules.lanzaboote
            ({ pkgs, lib, ... }: {

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
            })
          ];
        };

      fourforty = let
        system = "xf86_64-linux";
        hostname = "fourforty";
      in
        nixpkgs.lib.nixosSystem {
          specialArgs = {inherit system hostname username inputs;} // inputs;

          modules = [
            ./.
            ./hosts/fourforty
            ./modules/desktop/sway
            ./modules/core
            ./modules/dev
            ./modules/neovim
            stylix.nixosModules.stylix
            kmonad.nixosModules.default
          ];
        };

      cave = let
        system = "xf86_64-linux";
        hostname = "cave";
      in
        nixpkgs.lib.nixosSystem {
          specialArgs = {inherit system hostname username inputs;} // inputs;

          modules = [
            ./.
            ./hosts/cave
            ./modules/nixos/qbittorrent-service
            stylix.nixosModules.stylix
          ];
        };
    };

    #formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;
  };
}
