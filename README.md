# dotfiles

Hand-rolled symlink-based dotfile manager. Uses a `dots.toml` spec file to
declaratively map repo paths to system config paths via symlinks.

## Quick Start

### Linux

```bash
bash bootstrap.sh
```

### Windows

```cmd
cmd /C bootstrap.bat
```

## Day-to-Day Usage

```
pixi run sync        # create all symlinks for current platform
pixi run status      # show state of all links (linked | missing | conflict)
pixi run unlink      # remove all managed symlinks
```

### Adding a new dotfile

```
pixi run add <source> <target>
pixi run add <source> <target> -- --platforms linux-64
```

Example:

```
pixi run add fish ~/.config/fish
pixi run add nushell/env.nu ~/.config/nushell/env.nu -- --platforms linux-64
```

### Removing an entry

```
pixi run remove <source>
```

## dots.toml Format

```toml
# Cross-platform (no platforms key = applies everywhere)
[[links]]
source = "lazygit"
target = "~/.config/lazygit"

# Platform-specific target path
[[links]]
source = "nvim"
target = "~/.config/nvim"
platforms = ["linux-64"]

[[links]]
source = "nvim"
target = "~/AppData/Local/nvim"
platforms = ["win-64"]

# Platform-specific source file
[[links]]
source = "nushell/config.nu"
target = "~/.config/nushell/config.nu"
platforms = ["linux-64"]
```

- `source` - path relative to the repo root
- `target` - destination path; `~` is expanded to the home directory
- `platforms` - optional; absent means all platforms. Values: `"linux-64"`, `"win-64"`

## Conflict Handling

When a target already exists and is not the correct symlink, `sync` moves it to
`<target>.bak` before creating the symlink. Backup files are excluded from git
via `.gitignore`.

## Bootstrap Flow

```
bash bootstrap.sh
  -> installs pixi (if absent)
  -> pixi global install nushell
  -> nu scripts/install.nu
       -> nu scripts/dots.nu sync    (create symlinks)
       -> pixi global sync           (install global tools)
       -> setup_nu                   (clone nu_scripts)
       -> setup_opencode             (install opencode-ai)
       -> nu scripts/finalize-linux.nu  (or finalize-windows.nu)
```
