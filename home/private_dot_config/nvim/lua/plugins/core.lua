return {
  -- ============================================================================
  -- CORE SYSTEM & DEPENDENCIES
  -- ============================================================================
  -- Lua utility library (required by many plugins)
  'nvim-lua/plenary.nvim',
  -- NvChad UI framework
  {
    'nvchad/ui',
    config = function()
      require 'nvchad'
    end,
  },

  -- NvChad utilities
  'nvchad/volt',

  -- Lazy.nvim package manager
  { 'folke/lazy.nvim', version = '*' },

  -- Lua development for Neovim
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    cmd = 'LazyDev',
    opts = {
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
        { path = 'snacks.nvim', words = { 'Snacks' } },
      },
    },
  },

  -- Snacks.nvim - Swiss Army knife utility plugin
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    opts = {},
  },

  -- NeoVim UI library
  { 'MunifTanjim/nui.nvim', lazy = true },
}
