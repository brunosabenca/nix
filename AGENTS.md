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

## Flake Input Conventions

### `// inputs` spread in `specialArgs`
`mkHost` passes `// inputs` into `specialArgs`, making every flake input available as a direct module argument alongside the explicit `inputs` arg. This is intentional for this personal config — it avoids verbosity like `inputs.agenix` in favour of plain `agenix`.

**Do not remove `// inputs`** — modules such as `default.nix` (`agenix`, `neovim`, `home-manager`) and `modules/copyparty` (`copyparty`) rely on it.

### Explicit destructuring in `outputs`
Only destructure inputs in the `outputs` function args when they are used **directly in `flake.nix`** (e.g. `stylix.nixosModules.stylix`, `nur.modules.nixos.default`). Inputs only used inside modules via the `inputs` arg or `// inputs` spread should not appear in the `outputs` destructuring.

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

## State Version Management

### Two Different stateVersion Options

| Option | Location | Can Bump? | Risk | Controls |
|--------|----------|-----------|------|----------|
| `home.stateVersion` | `modules/core/nix/default.nix` | ✅ Yes | Low | User apps (GTK, Git, shells) |
| `system.stateVersion` | `hosts/<hostname>/hardware-configuration.nix` | ❌ **NEVER** | **HIGH** | Databases, system services |

**Rule**: Only modify `home.stateVersion`. Never touch `system.stateVersion`.

**Current values:**
- `home.stateVersion`: "26.05" (all hosts)
- `system.stateVersion`: monolith=23.05, firefly=25.11, cave=24.05, fourforty=23.11

**Need newer software?** Explicitly set package versions:
```nix
services.postgresql.package = pkgs.postgresql_17;  # Don't bump stateVersion
```
