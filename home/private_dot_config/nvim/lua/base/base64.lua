return {
  'nvim-lua/plenary.nvim',
  {
    'nvchad/ui',
    config = function()
      require 'nvchad'
    end,
  },
  {
    'nvchad/base46',
    lazy = false,
    config = function()
      require('base46').load_all_highlights()
    end,
  },
  'nvchad/volt',
}
