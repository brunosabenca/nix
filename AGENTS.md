# Nix Configuration - Agent Guidelines

## Project Structure

### Module Organization
- **Use directory modules** with `default.nix` instead of flat `.nix` files
- Pattern: `modules/<category>/<name>/default.nix`
- This allows easy expansion and keeps structure consistent

### Host Configuration
- Use `mkHost` helper in `flake.nix` to DRY host definitions
- Each host imports from `./hosts/<hostname>/`
- Common modules imported via `extraModules` parameter

### Core Module Categories

#### `modules/core/`
System-level configurations:
- `locale/` - Timezone and i18n settings
- `audio/` - Pipewire, X11, sound settings
- `users/` - User account definitions
- `terminal/` - Shell configurations (zsh, fish, kitty)
- `git/` - Git configuration
- `nix/` - Nix package manager settings
- `pkgs/` - Core system packages
- `man/` - Manual pages
- `mpv/` - Media player config

#### `modules/desktop/`
Desktop environment configurations:
- `niri/` - Niri compositor setup

#### `modules/dev/`
Development tools and environments:
- `lua/` - Lua development
- Language servers, build tools, etc.

#### `modules/home/`
Home-manager configurations:
- User packages
- Application settings
- MIME associations

#### `modules/<app>/`
Individual application modules:
- `firefox/`, `neovim/`, `vscode/`, etc.

## Configuration Patterns

### Imports
```nix
{
  imports = [
    ./core
    ./desktop
    ./dev
    ./stylix
  ];
}
```

### Host Definition
```nix
mkHost {
  hostname = "example";
  extraModules = [
    ./modules/desktop/niri
    ./modules/core
    # ...
  ];
}
```

## Design Principles

1. **DRY**: Use helper functions (`mkHost`) to avoid repetition
2. **Consistency**: All modules follow directory structure
3. **Separation of Concerns**: Group related configs in dedicated modules
4. **Composability**: Hosts pick and choose modules via `extraModules`
5. **No duplication**: Remove redundant settings (e.g., home-manager options)

## Common Tasks

### Adding a new host
1. Create `hosts/<hostname>/default.nix`
2. Add to `flake.nix` using `mkHost`
3. Specify `extraModules` for that host's needs

### Adding a new module
1. Create directory: `modules/<category>/<name>/`
2. Add `default.nix` with configuration
3. Import in appropriate parent `default.nix`

### Adding packages
- System packages → `modules/core/pkgs/default.nix`
- User packages → `modules/home/default.nix`
- Host-specific → Host's `default.nix`

## File Locations

- Root config: `default.nix`
- Flake: `flake.nix`
- Home config: `modules/home/default.nix` (not `home.nix`)
- Secrets: `secrets.nix` (not tracked)
- Host hardware: `hosts/<hostname>/hardware-configuration.nix`

## Testing

Always verify after changes:
```bash
sudo nixos-rebuild switch --flake .
```

Or build without switching:
```bash
nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel
```
