-- Markdown extras

local add = MiniDeps.add

-- Markdown rendering with markview.nvim
add 'OXY2DEV/markview.nvim'

require('markview').setup {
  modes = { 'n', 'no', 'c' }, -- Not in insert mode
  hybrid_modes = { 'n' },
  callbacks = {
    on_enable = function(_, win)
      vim.wo[win].conceallevel = 2
      vim.wo[win].concealcursor = 'nc'
    end,
  },
}

-- Toggle markview
vim.keymap.set('n', '<leader>tm', '<cmd>Markview toggle<CR>', { desc = 'Toggle markdown preview' })
