# Neovim 0.11.x Configuration

Clean, maintainable Neovim configuration built from first principles following the greenfield rewrite spec.

## Features

### Core IDE Capabilities
- **LSP**: Full language server support with classic navigation (gd/gr/gi/gD)
- **Completion**: blink.cmp (Rust-based, insert-friendly)
- **Formatting**: conform.nvim with format-on-save
- **Linting**: nvim-lint with auto-lint on save
- **Syntax**: nvim-treesitter with textobjects
- **Clipboard**: OSC52 support for remote SSH sessions

### Language Support
- **C/C++**: clangd + clang-format + clang-tidy
- **CMake**: cmake-language-server
- **Python**: basedpyright + ruff (format + lint)
- **JavaScript/TypeScript**: vtsls + biome (format + lint)
- **Shell**: bashls + shellcheck + shfmt
- **Nushell**: built-in LSP (nu --lsp)
- **Config formats**: jsonls, yamlls, taplo
- **Markdown**: marksman + mdformat + markview.nvim
- **Lua**: lua_ls with Neovim runtime awareness

### C/C++ Workflow
- **CMake integration**: cmake-tools.nvim
  - Select project root, build dir, preset
  - Configure, build, run, test (CTest)
- **Debugging**: nvim-dap + codelldb + nvim-dap-ui
  - Launch executable, attach to process, debug tests
  - Reliable prompts (no enhanced vim.ui.input/select)

### Navigation & Files
- **Fuzzy finder**: fzf-lua (assumes ripgrep installed)
- **File explorer**: mini.files
- **Quick marks**: harpoon2 (mark files, jump to 1-4)
- **Yank path**: Global and mini.files mappings for absolute/relative/filename
- **Root detection**: LSP root → git root → cwd

### UI
- **Theme**: base46 (colorscheme only, default: onedark)
- **Statusline**: lualine
- **Buffer tabs**: bufferline.nvim
- **Keymap hints**: which-key
- **Indent guides**: indent-blankline (ibl)
- **Notifications**: nvim-notify
- **Diagnostics UI**: Trouble.nvim

### Editing Helpers
- **Autopairs**: mini.pairs
- **Surround**: mini.surround
- **Comments**: mini.comment
- **Sessions**: mini.sessions
- **Snippets**: LuaSnip + friendly-snippets
- **Motion**: flash.nvim (leap-style jump)
- **Refactoring**: refactoring.nvim (extract function/variable, inline, etc.)

### Git
- **Gutter signs**: gitsigns.nvim
- **Hunk actions**: stage, reset, preview, blame

## Installation

1. Backup your existing config:
   ```bash
   mv ~/.config/nvim ~/.config/nvim.bak
   ```

2. Copy this config:
   ```bash
   cp -r nvim-new ~/.config/nvim
   ```

3. Launch Neovim:
   ```bash
   nvim
   ```

4. mini.deps will auto-install on first launch
5. Mason will auto-install LSP servers and tools

## Key Mappings

### General
- `<Space>` - Leader key
- `<leader>w` - Save file
- `<leader>q` - Quit
- `<Esc>` - Clear search highlight

### Navigation
- `<C-h/j/k/l>` - Move between windows
- `<S-h/l>` - Previous/next buffer
- `<leader>bd` - Delete buffer

### LSP
- `gd` - Go to definition
- `gD` - Go to declaration
- `gi` - Go to implementation
- `gr` - Go to references
- `K` - Hover documentation
- `<leader>rn` - Rename
- `<leader>ca` - Code action
- `[d` / `]d` - Previous/next diagnostic
- `<leader>e` - Show diagnostic float
- `<leader>f` - Format buffer

### Fuzzy Finder
- `<leader>ff` - Find files
- `<leader>fg` - Live grep
- `<leader>fb` - Find buffers
- `<leader>fh` - Find help
- `<leader>fr` - Recent files

### File Explorer
- `<leader>e` - Open file explorer (current file)
- `<leader>E` - Open file explorer (cwd)
- In explorer:
  - `gy` - Yank absolute path
  - `gY` - Yank relative path
  - `gn` - Yank filename

### Yank Path (Global)
- `<leader>ya` - Yank absolute path
- `<leader>yr` - Yank relative path
- `<leader>yn` - Yank filename

### Harpoon Marks
- `<leader>a` - Add file to harpoon
- `<C-e>` - Toggle harpoon menu
- `<leader>1-4` - Jump to harpoon file 1-4

### Git
- `]h` / `[h` - Next/previous hunk
- `<leader>gs` - Stage hunk
- `<leader>gr` - Reset hunk
- `<leader>gp` - Preview hunk
- `<leader>gb` - Blame line

### CMake
- `<leader>cg` - CMake generate
- `<leader>cb` - CMake build
- `<leader>cr` - CMake run
- `<leader>ct` - CMake run test
- `<leader>cs` - Select build type
- `<leader>cT` - Select build target
- `<leader>cd` - CMake debug

### Debug (DAP)
- `<leader>db` - Toggle breakpoint
- `<leader>dc` - Continue
- `<leader>dn` - Step over
- `<leader>di` - Step into
- `<leader>do` - Step out
- `<leader>dr` - Toggle REPL
- `<leader>du` - Toggle DAP UI
- `<leader>dl` - Run last
- `<leader>dt` - Terminate

### Trouble
- `<leader>xx` - Toggle diagnostics
- `<leader>xX` - Buffer diagnostics
- `<leader>xs` - Symbols
- `<leader>xl` - LSP references

### Markdown
- `<leader>tm` - Toggle markdown preview

### Refactoring
- `<leader>re` - Extract function (visual mode)
- `<leader>rf` - Extract function to file (visual mode)
- `<leader>rv` - Extract variable (visual mode)
- `<leader>rI` - Inline function
- `<leader>ri` - Inline variable
- `<leader>rb` - Extract block
- `<leader>rbf` - Extract block to file
- `<leader>rr` - Select refactor (prompt)

## Diagnostics UX

- Virtual text: ON
- Signs: ON (Nerd Font icons)
- Underline: ON
- Update in insert mode: OFF
- Float behavior: Hybrid (diagnostics on CursorHold, hover on K)

## Root Detection

Priority order:
1. LSP root directory
2. Git root (.git)
3. Current working directory

Used for:
- Yank path feature (relative paths)
- fzf-lua project searches
- CMake workflow defaults

## Clipboard (OSC52 Support)

This config uses OSC52 for clipboard operations, which enables copy/paste to work seamlessly in remote SSH sessions.

- Yank operations automatically copy to your local clipboard via OSC52
- Works with tmux, screen, and most modern terminal emulators
- No additional configuration needed for remote sessions

To use:
- Yank text normally with `y` in visual mode or `yy` for line
- Text is automatically available in your local system clipboard
- Works with `<leader>ya/yr/yn` yank-path commands too

## Format on Save

Enabled for:
- C/C++ (clang-format)
- Python (ruff format)
- JavaScript/TypeScript (biome)
- Shell (shfmt)
- Markdown (mdformat)
- YAML (prettier)
- TOML (taplo)
- Lua (stylua)

## Plugin Manager

Uses mini.deps (part of mini.nvim) for plugin management.

## Customization

### Change Theme

Edit `lua/plugins/ui.lua` and change:
```lua
vim.g.base46_theme = 'onedark' -- Change to your preferred theme
```

Available themes: See base46 documentation

### Modify LSP Servers

Edit `lua/core/lsp.lua` to add/remove servers in the `servers` table.

### Add Formatters/Linters

- Formatters: Edit `lua/core/formatting.lua`
- Linters: Edit `lua/core/linting.lua`
- Ensure tools installed: Edit `lua/core/tools.lua`

## Dependencies

External dependencies (assumed installed):
- **ripgrep** (rg) - Required for fzf-lua live_grep
- **Nerd Font** - Required for icons
- **Node.js** - Required for some LSP servers (vtsls, etc.)
- **Nushell** (nu) - Required for Nushell LSP support (if editing .nu files)

## Known Issues

### First Launch

On first launch, some Mason tools may fail to install due to network or platform issues:
- **clang-format** - May require system LLVM/Clang installed
- **ruff** - May require Python setuptools
- **mdformat** - May require Python pip
- **cmake-language-server** - May require Python and CMake
- **basedpyright** - May require Node.js and npm

These can be manually installed via Mason later:
- Open Mason: `:Mason`
- Navigate to the failed package
- Press `i` to install

### Nushell LSP

Nushell LSP is not available via Mason. It requires the `nu` binary installed on your system:
```bash
# Install nushell (example for Linux)
cargo install nu

# Or via package manager
# Arch: sudo pacman -S nushell
# Ubuntu: sudo snap install nushell
```

The LSP is automatically configured to use `nu --lsp` when editing `.nu` files.

## Non-Goals (Baseline)

This config explicitly avoids:
- cmdline/messages UI suite (no noice-style system)
- winbar breadcrumbs
- terminal toggle plugin (rely on zellij + :terminal)
- enhanced vim.ui.input/select UI (to protect DAP prompts)

## Structure

```
nvim-new/
├── init.lua                    # Entry point + mini.deps bootstrap
├── lua/
│   ├── core/
│   │   ├── options.lua        # Neovim options
│   │   ├── keymaps.lua        # Core keymaps
│   │   ├── autocmds.lua       # Autocommands
│   │   ├── diagnostics.lua    # Diagnostics config
│   │   ├── lsp.lua            # LSP setup
│   │   ├── formatting.lua     # conform.nvim
│   │   ├── linting.lua        # nvim-lint
│   │   ├── tools.lua          # mason-tool-installer
│   │   └── root.lua           # Root detection utilities
│   └── plugins/
│       ├── init.lua           # Plugin loading orchestration
│       ├── ui.lua             # UI layer plugins
│       ├── treesitter.lua     # Treesitter config
│       ├── editing.lua        # Editing helpers
│       ├── navigation.lua     # Navigation + files
│       ├── git.lua            # Git integration
│       ├── languages.lua      # Language-specific
│       ├── cpp_workflow.lua   # CMake + DAP
│       └── markdown.lua       # Markdown extras
└── README.md                  # This file
```

## Acceptance Criteria

- [x] Startup on Neovim 0.11.x with no errors
- [x] base46 loads as active colorscheme
- [x] blink.cmp provides completion with LSP + snippets
- [x] LSP works with classic navigation across all languages
- [x] Format-on-save works per filetype
- [x] Linting works where applicable
- [x] CMake workflow supports select/configure/build/run/test
- [x] DAP with codelldb supports launch/attach/debug tests
- [x] fzf-lua works for files and search
- [x] gitsigns shows hunks in gutter
- [x] mini.files is only explorer with yank paths
- [x] Bufferline shows buffer tabs
- [x] lualine active, which-key works
- [x] Trouble shows diagnostics/symbols
- [x] notify displays notifications
- [x] Editing helpers active (autopairs, surround, comment, sessions, flash, snippets)
