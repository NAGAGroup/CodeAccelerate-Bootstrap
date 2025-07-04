# AGENTS.md - Neovim Configuration Guide

## Build/Test/Lint Commands
This is a Neovim configuration (based on kickstart.nvim), not a development project. No build/test commands apply.
- Format Lua files: `stylua .` (via conform.nvim)
- Neovim health check: `nvim --headless +'checkhealth' +qa`

## Code Style Guidelines

### File Structure
- Main config entry: `init.lua`
- Core config: `lua/config/` (options, keymaps, autocmds, etc.)
- Base plugins: `lua/base/`
- Plugin configs: `lua/plugins/`
- Extra features: `lua/extras/`

### Lua Style
- Use tabs for indentation (shiftwidth=2, tabstop=2)
- Snake_case for variables and functions
- String quotes: prefer double quotes `"string"`
- Table formatting: use proper alignment and trailing commas
- Plugin table structure: follow lazy.nvim format with proper keys, opts, config functions

### Plugin Configuration Patterns
- Use `opts = {}` for simple plugin configuration
- Use `config = function(_, opts)` for complex setup
- Group related keymaps in plugin definitions
- Use lazy loading with `event`, `cmd`, `ft`, `keys` appropriately
- Dependencies declared explicitly with `dependencies = {}`