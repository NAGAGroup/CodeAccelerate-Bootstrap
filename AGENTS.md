# Dotfiles Repository - Agent Guidelines

## Quick Reference

### Commands

- **Sync dotfiles**: `pixi run sync` or `nu scripts/dots.nu sync`
- **Check status**: `pixi run status` or `nu scripts/dots.nu status`
- **Unlink all**: `pixi run unlink` or `nu scripts/dots.nu unlink`
- **Add entry**: `nu scripts/dots.nu add <source> <target> [--platforms linux-64,win-64]`
- **Remove entry**: `nu scripts/dots.nu remove <source>`
- **Bootstrap (Linux)**: `bash bootstrap.sh`
- **Bootstrap (Windows)**: `cmd /C bootstrap.bat`

### Code Style Guidelines

- **Nushell**: Use `try-catch` patterns, avoid `cd` (use `path join` and `git -C`), no shell operators like `&&` (use `;` or `and`)
- **TOML**: 2-space indent not required - follow existing file style
- **All files**: Unix line endings (LF), final newline required

### Project Structure

```
~/dotfiles/
├── dots.toml          <- spec file: all link mappings
├── scripts/
│   ├── dots.nu        <- core engine: sync | unlink | status | add | remove
│   ├── install.nu     <- post-bootstrap installer (called by bootstrap scripts)
│   ├── finalize-linux.nu   <- Linux-specific post-install steps
│   └── finalize-windows.nu <- Windows-specific post-install steps
├── bootstrap.sh       <- Linux entry point (bash bootstrap.sh)
├── bootstrap.bat      <- Windows entry point (cmd /C bootstrap.bat)
├── pixi.toml          <- pixi project: tasks for day-to-day operations
├── nvim/              <- Neovim config
├── nushell/           <- Nushell config (config.nu, env.nu)
├── kitty/             <- Kitty terminal config
├── zellij/            <- Zellij config
├── lazygit/           <- Lazygit config
└── pixi-global/       <- pixi-global manifests (linux-64.toml, win-64.toml)
```

## Architecture Notes

- `dots.toml` is the single source of truth for all symlink mappings
- Platform detection: `linux-64` or `win-64` (matches pixi platform naming)
- Entries without a `platforms` key apply to all platforms
- Conflict handling: existing files are backed up to `<path>.bak` before linking
- Windows fallback: directory symlinks fall back to junctions automatically if Developer Mode is not enabled
- `pixi global sync` is called from `scripts/install.nu`, NOT from within any pixi task (avoids env pollution)

## dots.toml Schema

```toml
# Cross-platform entry (no platforms key)
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
