--[[
=====================================================================
                    Neovim Configuration - Entry Point
=====================================================================

This is the main entry point for the Neovim configuration. It orchestrates
the loading of all configuration modules in the correct order.

LOADING ORDER (important for proper initialization):
  1. utils.utils    - Global utility functions (available as NvimLuaUtils)
  2. config.options - Vim options, global variables, and editor settings
  3. config.autocmds - Autocommands for file events, UI enhancements, etc.
  4. config.lazy    - Plugin manager bootstrap and plugin loading
  5. config.keymaps - Key mappings (loaded after plugins for proper integration)
  6. vim.ui.select  - Custom FzfLua-based picker for vim.ui.select
  7. base46 cache   - NVChad theme highlighting

DIRECTORY STRUCTURE:
  lua/
  ├── config/           - Core Neovim configuration
  │   ├── options.lua   - Editor options and settings
  │   ├── keymaps.lua   - Global key mappings
  │   ├── autocmds.lua  - Autocommands
  │   ├── lazy.lua      - Plugin manager setup
  │   └── lsp_keymaps.lua - LSP-specific keybindings
  ├── plugins/
  │   ├── core/         - Essential plugins (LSP, completion, editor, etc.)
  │   ├── ext/          - Optional/extension plugins (Copilot, etc.)
  │   └── lang/         - Language-specific plugins
  ├── utils/
  │   └── utils.lua     - Utility functions
  └── chadrc.lua        - NVChad UI configuration

GLOBAL VARIABLES:
  NvimLuaUtils - Global access to utility functions from utils/utils.lua
  Snacks       - Global access to snacks.nvim features (set by snacks.nvim)

@see config.options for editor settings
@see config.keymaps for key mappings reference
@see config.lazy for plugin configuration
]]

-- Create global instance for easy access to utility functions
-- This allows any module to use NvimLuaUtils.function_name() without requiring
_G.NvimLuaUtils = require 'utils.utils'

-- Load core Neovim configurations in order
-- Options must be loaded first as they set leader keys and other fundamentals
require 'config.options' -- Options and settings

-- Autocommands are loaded before plugins to ensure they're ready
require 'config.autocmds' -- Auto commands

-- Bootstrap lazy.nvim and load all plugins
-- This also initializes the plugin manager if it's not installed
require 'config.lazy'

-- Load keymaps after plugins to ensure all plugin-specific mappings work
-- Many keymaps depend on plugins being loaded (e.g., Snacks, FzfLua)
require 'config.keymaps' -- Key mappings

--[[
  Custom vim.ui.select implementation using FzfLua
  
  This replaces Neovim's default vim.ui.select with a FzfLua-based picker
  that provides a better UX with fuzzy finding, previews, and consistent styling.
  
  Features:
  - Fuzzy filtering of options
  - Consistent styling with LazyVim-inspired UI
  - Special handling for code actions (vertical layout with preview)
  - Centered title with cleaned-up prompt text
  
  @param items table - List of items to select from
  @param opts table - Options including prompt, format_item, and kind
  @param on_choice function - Callback called with (selected_item, index)
]]
local function set_picker()
  vim.ui.select = function(items, opts, on_choice)
    local format_item = opts.format_item or tostring
    local choices = {}

    -- Format the items
    for i, item in ipairs(items) do
      choices[i] = format_item(item)
    end

    -- Base fzf options
    local fzf_opts = {
      prompt = opts.prompt or 'Select one of:',
      actions = {
        ['default'] = function(selected)
          if #selected == 0 then
            on_choice(nil, nil)
            return
          end

          -- Find the original item
          for i, choice in ipairs(choices) do
            if choice == selected[1] then
              on_choice(items[i], i)
              return
            end
          end
        end,
      },
    }

    -- Apply the LazyVim styling
    fzf_opts = vim.tbl_deep_extend('force', fzf_opts, {
      prompt = ' ',
      winopts = {
        title = ' ' .. vim.trim((opts.prompt or 'Select'):gsub('%s*:%s*$', '')) .. ' ',
        title_pos = 'center',
      },
    })

    -- Handle special case for code actions (based on LazyVim's code)
    if opts.kind == 'codeaction' then
      fzf_opts = vim.tbl_deep_extend('force', fzf_opts, {
        winopts = {
          layout = 'vertical',
          -- height is number of items minus 15 lines for the preview, with a max of 80% screen height
          height = math.floor(math.min(vim.o.lines * 0.8 - 16, #choices + 2) + 0.5) + 16,
          width = 0.5,
        },
      })
    else
      -- Default styling for non-codeaction selects
      fzf_opts = vim.tbl_deep_extend('force', fzf_opts, {
        winopts = {
          width = 0.5,
          -- height is number of items, with a max of 80% screen height
          height = math.floor(math.min(vim.o.lines * 0.8, #choices + 2) + 0.5),
        },
      })
    end

    -- Execute fzf with our combined options
    require('fzf-lua').fzf_exec(choices, fzf_opts)
  end
end
set_picker()

--[[
  Load NVChad Base46 Theme Cache
  
  Base46 pre-compiles theme highlights into cache files for faster startup.
  This loop loads all cached highlight files from the base46_cache directory
  (defined in config/options.lua as vim.g.base46_cache).
  
  The cache is regenerated when:
  - Theme is changed via :lua require('nvchad.themes').open()
  - NvChad is updated
  - Cache is manually cleared
]]
for _, v in ipairs(vim.fn.readdir(vim.g.base46_cache)) do
  dofile(vim.g.base46_cache .. v)
end
