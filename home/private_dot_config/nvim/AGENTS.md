# Neovim Config Development Guidelines

## Commands
- **Format Lua**: `stylua --check lua/` or `stylua lua/` (160-char line width, Unix line endings)
- **Format JS/TS**: `prettier --check "**/*.{js,ts,jsx,tsx}"` or `prettier --write "**/*.{js,ts,jsx,tsx}"`
- **Lint**: No dedicated linter; rely on Lua LSP diagnostics
- **Test**: No test suite; this is a Neovim configuration (test manually in Neovim)

## Code Style
- **Indentation**: 2 spaces (Lua), 4 spaces (JS/TS)
- **Line length**: 160 characters max for Lua
- **Quotes**: Single quotes preferred (both Lua and JS/TS)
- **Trailing commas**: None in Lua, ES5 style in JS/TS
- **Function calls**: Omit parentheses in Lua when possible (e.g., `require 'module'`)
- **Naming**: `snake_case` for Lua variables/functions; `CamelCase` for plugin configs and JS/TS

## Imports & Requires
- Group requires: standard library → third-party → local modules
- Use `require 'module'` without parentheses when no options passed
- Use `require('module')` with parentheses for method calls (e.g., `require('module').setup()`)
- Check module existence with pcall if optional: `local ok, mod = pcall(require, 'module')`

## Architecture
- **Plugins**: Each in `lua/plugins/{core,ext,lang}/` (core=essential, ext=optional, lang=language-specific)
- **Config**: General settings in `lua/config/` (keymaps, options, autocmds, LSP keymaps)
- **Utils**: Helper functions in `lua/utils/`
- **Entry point**: `init.lua` loads lazy.nvim and bootstraps config

## Error Handling
- Use `pcall()` for protected calls that might fail
- Check for `nil` before accessing properties (`if foo then foo.bar() end`)
- Add descriptive error messages for edge cases