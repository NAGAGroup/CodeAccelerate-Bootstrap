--[[
=====================================================================
                    Neovim Plugins - Snippets
=====================================================================

This file configures the snippet engine and snippet collections.

PLUGIN OVERVIEW:

  Snippet Engine:
    - LuaSnip               : Fast snippet engine written in Lua

  Snippet Collections:
    - friendly-snippets     : Community-maintained snippet collection

CONFIGURATION:

  Snippets are loaded from two sources:
  1. friendly-snippets: VSCode-style snippets for many languages
  2. Custom snippets: From ~/.config/nvim/snippets/ directory

  LuaSnip is configured with:
  - history = true        : Remember last snippet for re-expansion
  - delete_check_events   : Clear snippets on text change

  Integration with blink.cmp is configured in coding.lua via the
  'snippets.preset = luasnip' option.

@see lua/plugins/core/coding.lua for blink.cmp snippet integration
@see https://github.com/L3MON4D3/LuaSnip
]]

return {
  -- ============================================================================
  -- SNIPPETS
  -- ============================================================================

  -- Disable builtin snippet support in favor of LuaSnip
  { 'garymjr/nvim-snippets', enabled = false },

  --[[
    LuaSnip - Snippet Engine
    
    A fast Lua-based snippet engine that supports:
    - VSCode snippet format (from friendly-snippets)
    - Custom Lua snippets
    - Dynamic snippets with Lua expressions
    - Jump points and choice nodes
  ]]
  {
    'L3MON4D3/LuaSnip',
    lazy = true,
    dependencies = {
      {
        'rafamadriz/friendly-snippets',
        config = function()
          require('luasnip.loaders.from_vscode').lazy_load()
          require('luasnip.loaders.from_vscode').lazy_load { paths = { vim.fn.stdpath 'config' .. '/snippets' } }
        end,
      },
    },
    opts = {
      history = true,
      delete_check_events = 'TextChanged',
    },
  },
}
