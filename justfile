# just is a command runner, Justfile is very similar to Makefile, but simpler.
# Shamelessly stolen from https://nixos-and-flakes.thiscute.world/best-practices/simplify-nixos-related-commands

# Build and deploy this NixOS derivation
deploy:
    sudo nixos-rebuild switch --flake .

# Show what will be built vs fetched
dry hostname=`hostname`:
    nix build '.#nixosConfigurations.{{hostname}}.config.system.build.toplevel' --dry-run 2>&1

# Print all available just commands
help:
    @just --list

# Build and stage for next boot (use when critical components change)
boot:
    sudo nixos-rebuild boot --flake .

# Build and deploy this NixOS derivation
build:
    sudo nixos-rebuild build --flake .

# Build and deploy this NixOS derivation
test:
    sudo nixos-rebuild test --flake .

# Print debug info while attempting to build and deploy this NixOS derivation
debug:
    sudo nixos-rebuild build --flake . --show-trace --verbose --option eval-cache false

# Update all flake inputs (nixCats-nvim first, then main flake)
update:
    cd /home/bruno/git/nixCats-nvim && just update
    sudo nix flake update

# Update a specific flake input
up input:
    sudo nix flake update {{ input }}

# Open a nix repl
repl:
    nix repl -f flake:nixpkgs

# Remove all generations older than 7 days
clean:
    sudo nix profile wipe-history --profile /nix/var/nix/profiles/system  --older-than 7d

# Garbage collect all unused nix store entries
gc:
    sudo nix-collect-garbage --delete-old