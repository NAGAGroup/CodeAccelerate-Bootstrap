# Neovim Config Development Guidelines

## Commands
- Format Lua: `stylua --check lua/` or `stylua lua/`
- Format JS/TS: `prettier --check "**/*.{js,ts,jsx,tsx}"` or `prettier --write "**/*.{js,ts,jsx,tsx}"`
- Lint: No specific linter found, rely on Lua diagnostics via LSP

## Code Style
- Indentation: 2 spaces (Lua), 4 spaces (JS/TS)
- Line length: 160 characters max for Lua
- Quotes: Prefer single quotes (both Lua and JS/TS)
- No trailing commas in Lua, ES5 trailing commas in JS
- Function calls without parentheses in Lua when possible
- Snake_case for variables and functions in Lua
- CamelCase for plugin configuration and JS/TS code
- Add descriptive comments for complex logic

## Architecture
- Plugin configuration: Each plugin has its own file in `lua/plugins/`
- Core functionality: Base settings in `lua/base/`
- Configuration: General settings in `lua/config/`
- Optional features: Extended functionality in `lua/extras/`

## Error Handling
- Use pcall for protected calls that might fail
- Check for nil values before accessing properties
- Handle edge cases with meaningful error messages