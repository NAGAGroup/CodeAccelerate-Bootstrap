# Dotfiles Repository - Agent Guidelines

## Quick Reference

### Build & Format Commands
- **Lua Format Check**: `stylua --check lua/` or `stylua lua/` (160-char line width)
- **JS/TS Format**: `prettier --check "**/*.{js,ts,jsx,tsx}"` or `prettier --write "**/*.{js,ts,jsx,tsx}"`
- **Bootstrap**: `bash bootstrap.sh` (Linux) or `cmd /c bootstrap.bat` (Windows)

### Code Style Guidelines
- **Lua**: 2-space indent, single quotes, max 160 chars, snake_case variables, function calls without parentheses when possible
- **JS/TS**: 4-space indent, single quotes, ES5 trailing commas, CamelCase
- **Shell (Nushell)**: Use pixi environment, avoid shell operators like `&&` (use `;` or `and`)
- **All files**: Unix line endings (LF), final newline required

### Project Structure
- `home/private_dot_config/nvim/lua/`: Neovim configuration (LazyVim-based)
  - `config/`: Core settings (keymaps, options, autocmds, LSP)
  - `plugins/`: Plugin configurations (coding, git, navigation, UI, language support)
  - `utils/`: Utility functions
- `home/private_dot_config/`: Shell (fish, nushell), terminal (kitty, zellij), other tools
- `scripts/`: Installation and setup scripts
- `.editorconfig`: Universal formatting rules

### Error Handling & Imports
- **Lua**: Use `pcall()` for protected calls, check `nil` values before accessing properties
- **Imports**: Group by standard library, third-party, then local modules
- **Nushell**: Use `try-catch` patterns, avoid pipe operators in conditions

## Architecture Notes
- Cross-platform support: Windows (win-64) and Linux (linux-64) via pixi
- Chezmoi handles dotfile templating and platform-specific installations
- Development focus: C++ toolchain, Nushell shell, Neovim IDE
