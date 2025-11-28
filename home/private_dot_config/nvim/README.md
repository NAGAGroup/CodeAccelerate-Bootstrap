# Neovim Configuration

A modular, well-documented Neovim configuration built on [lazy.nvim](https://github.com/folke/lazy.nvim) with NvChad UI components.

## Features

- **Modular Architecture**: Organized plugin structure with core, language-specific, and extension categories
- **Comprehensive LSP Support**: Pre-configured language servers via Mason with intelligent keybindings
- **Modern Completion**: Blink.cmp with snippet support and Copilot integration
- **Efficient Navigation**: FZF-lua for fuzzy finding, Trouble for diagnostics, flash.nvim for motions
- **Git Integration**: Diffview, gitsigns for seamless version control workflows
- **Beautiful UI**: NvChad theme system with statusline, bufferline, and Noice notifications

## Requirements

- Neovim >= 0.10.0
- Git
- A [Nerd Font](https://www.nerdfonts.com/) (recommended: JetBrainsMono Nerd Font)
- ripgrep (`rg`) for live grep functionality
- fd for file finding
- A C compiler (gcc/clang) for treesitter

## Structure

```
lua/
├── config/                    # Core Neovim configuration
│   ├── autocmds.lua           # Autocommands (highlight on yank, etc.)
│   ├── keymaps.lua            # General keybindings
│   ├── lazy.lua               # Plugin manager bootstrap
│   ├── lsp_keymaps.lua        # LSP-specific keybindings
│   └── options.lua            # Vim options and settings
├── plugins/
│   ├── core/                  # Essential plugins
│   │   ├── coding.lua         # LSP, completion, formatting, linting
│   │   ├── editor.lua         # Treesitter, text editing, which-key
│   │   ├── file-session-mgmt.lua  # File explorer, sessions
│   │   ├── git.lua            # Git integration (diffview, gitsigns)
│   │   ├── mini-hipatterns.lua    # Highlight patterns
│   │   ├── navigation.lua     # FZF, Trouble, todo-comments
│   │   ├── snippets.lua       # LuaSnip configuration
│   │   └── ui.lua             # UI components (noice, bufferline)
│   ├── ext/                   # Optional extensions
│   │   └── copilot.lua        # GitHub Copilot integration
│   └── lang/                  # Language-specific plugins
│       ├── base.lua           # Markdown support (markview)
│       └── c_lang.lua         # C/C++ tooling (clangd, cmake)
├── utils/
│   └── utils.lua              # Utility functions
└── chadrc.lua                 # NvChad theme configuration
```

## Key Bindings

Leader key: `<Space>`

### General

| Key | Description |
|-----|-------------|
| `<leader>w` | Save file |
| `<leader>qq` | Quit all |
| `<C-h/j/k/l>` | Window navigation |
| `<A-j/k>` | Move lines up/down |
| `j/k` | Smart line navigation (gj/gk) |

### LSP

| Key | Description |
|-----|-------------|
| `gd` | Go to definition |
| `gr` | Find references |
| `K` | Hover documentation |
| `<leader>ca` | Code actions |
| `<leader>cr` | Rename symbol |
| `<leader>cf` | Format buffer |
| `<leader>li` | Toggle inlay hints |
| `<leader>lR` | Restart LSP |

### Navigation

| Key | Description |
|-----|-------------|
| `<leader><space>` | Find files |
| `<leader>/` | Live grep |
| `<leader>fb` | Find buffers |
| `<leader>fr` | Recent files |
| `<leader>fg` | Git files |
| `<leader>xx` | Toggle Trouble diagnostics |
| `<leader>xq` | Quickfix list |

### Git

| Key | Description |
|-----|-------------|
| `<leader>gd` | Open Diffview |
| `<leader>gD` | Diffview file history |
| `<leader>gh` | Preview hunk |
| `<leader>gb` | Blame line |
| `]h` / `[h` | Next/prev hunk |

### File Management

| Key | Description |
|-----|-------------|
| `<leader>e` | Toggle file explorer |
| `<leader>qs` | Restore session |
| `<leader>qS` | Select session |

### Terminal

| Key | Description |
|-----|-------------|
| `<C-\>` | Toggle terminal |
| `<Esc><Esc>` | Exit terminal mode |

## Configured Language Servers

Managed via Mason, auto-installed on first launch:

- **Lua**: lua_ls (with Neovim API support)
- **C/C++**: clangd (with extensions)
- **Python**: basedpyright, ruff
- **Web**: ts_ls (TypeScript), html, cssls, tailwindcss
- **Data**: jsonls, yamlls, taplo (TOML)
- **Shell**: nushell
- **Markup**: marksman (Markdown)
- **CMake**: neocmake

## Formatters & Linters

Auto-installed via Mason:

- **stylua** - Lua formatting
- **prettier** - JS/TS/HTML/CSS/JSON/YAML formatting
- **clang-format** - C/C++ formatting
- **ruff** - Python linting/formatting
- **markdownlint** - Markdown linting

## Customization

### Adding Plugins

Create a new file in the appropriate `lua/plugins/` subdirectory:

```lua
-- lua/plugins/core/my-plugin.lua
return {
  'author/plugin-name',
  event = 'VeryLazy',  -- Lazy load
  opts = {
    -- Plugin options
  },
}
```

### Overriding Options

Edit `lua/config/options.lua` for Vim options or `lua/chadrc.lua` for theme settings.

### Adding Language Support

1. Add the language server to `ensure_installed` in `lua/plugins/core/coding.lua`
2. Add formatters/linters to the conform and nvim-lint configurations
3. Create a language-specific file in `lua/plugins/lang/` if needed

## Troubleshooting

### Check Plugin Status
```vim
:Lazy
```

### Check LSP Status
```vim
:LspInfo
:Mason
```

### Check Health
```vim
:checkhealth
```

### Profile Startup
```vim
:Lazy profile
```

## Credits

- Based on [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim)
- UI components from [NvChad](https://nvchad.com/)
- Plugin manager: [lazy.nvim](https://github.com/folke/lazy.nvim)

## License

MIT - See [LICENSE.md](LICENSE.md)
