# Neovim Configuration Refactoring Plan

This document tracks the refactoring work done and potential future improvements.

## Completed Work

### Phase 1: Plugin Consolidation ✅
- Consolidated all LSP servers into single `ensure_installed` list in `coding.lua`
- Consolidated all formatters/linters into single location
- Consolidated treesitter parsers into single `ensure_installed` list
- Simplified `lua/plugins/lang/` structure (base.lua + c_lang.lua)

### Phase 2: Functional Improvements ✅
- Added terminal toggle keymap (`<C-\>`)
- Added inlay hints toggle (`<leader>li`)
- Added LSP restart keymap (`<leader>lR`)
- Added diffview.nvim for git diffs
- Added nvim-bqf for better quickfix
- Added treesitter-context for sticky headers
- Improved gitsigns with current line blame
- Enhanced which-key descriptions
- Added flash.nvim jump indicators

### Phase 3: Documentation ✅
Added comprehensive file-level documentation to all config files:
- `init.lua` - Entry point documentation
- `lua/config/*.lua` - All config files documented
- `lua/plugins/core/*.lua` - All core plugins documented
- `lua/plugins/ext/*.lua` - Extension plugins documented
- `lua/plugins/lang/*.lua` - Language plugins documented
- `lua/utils/utils.lua` - Utility functions documented
- `lua/chadrc.lua` - Theme configuration documented

### Phase 4: Project Maintenance ✅
- Created custom README.md with accurate documentation
- Added `.luarc.json` for proper Lua LSP configuration

## Current Structure

```
lua/
├── config/                    # Core Neovim configuration
│   ├── autocmds.lua           # Autocommands
│   ├── keymaps.lua            # General keybindings
│   ├── lazy.lua               # Plugin manager bootstrap
│   ├── lsp_keymaps.lua        # LSP-specific keybindings
│   └── options.lua            # Vim options
├── plugins/
│   ├── core/                  # Essential plugins
│   │   ├── coding.lua         # LSP, completion, formatting
│   │   ├── editor.lua         # Treesitter, text editing
│   │   ├── file-session-mgmt.lua
│   │   ├── git.lua            # Git integration
│   │   ├── mini-hipatterns.lua
│   │   ├── navigation.lua     # FZF, Trouble
│   │   ├── snippets.lua       # LuaSnip
│   │   └── ui.lua             # UI components
│   ├── ext/                   # Optional extensions
│   │   └── copilot.lua        # GitHub Copilot
│   └── lang/                  # Language-specific
│       ├── base.lua           # Markdown
│       └── c_lang.lua         # C/C++ tooling
├── utils/
│   └── utils.lua              # Utility functions
└── chadrc.lua                 # NvChad theme config
```

## Potential Future Improvements

These are optional enhancements that could be considered:

### Type Annotations
- Add LuaLS `@class`, `@param`, `@return` annotations to utility functions
- Improves IDE support and documentation

### User Override System
- Create `lua/user/` directory (gitignored) for personal customizations
- Allow overriding options, keymaps, and plugins without modifying core files

### Performance Profiling
- Add startup profiling utilities
- Identify and optimize slow plugin loads

### Extended Language Support
- Add more language-specific configurations as needed
- Consider dedicated files for Python, Rust, Go, etc.

### Session Management
- Enhance project detection
- Add per-project `.nvim.lua` support

## Notes

- All documentation uses consistent format with header blocks
- Key mappings are documented in both README.md and individual files
- Plugin lazy-loading is already well-optimized via lazy.nvim
