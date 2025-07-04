return {
  -- Ayu colorscheme
  {
    'Shatur/neovim-ayu',
    lazy = false,
    priority = 1000, -- Load before other plugins
    opts = function()
      local colors = require 'ayu.colors'
      colors.generate(false)

      return {
        overrides = {
          MiniPickMatchCurrent = { bg = colors.selection_bg },
          MiniPickMatchMarked = { bg = colors.selection_inactive },
        },
      }
    end,
    config = function(_, opts)
      require('ayu').setup(opts)
    end,
  },

  -- Add more colorscheme plugins here
}
