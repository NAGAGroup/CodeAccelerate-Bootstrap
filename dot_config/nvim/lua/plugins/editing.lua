-- Editing helpers

local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

-- mini.pairs (autopairs)
later(function()
  require('mini.pairs').setup()
end)

-- mini.surround
later(function()
  require('mini.surround').setup {
    mappings = {
      add = 'sa',
      delete = 'sd',
      find = 'sf',
      find_left = 'sF',
      highlight = 'sh',
      replace = 'sr',
      update_n_lines = 'sn',
    },
  }
end)

-- mini.comment
later(function()
  require('mini.comment').setup {
    mappings = {
      -- Single mapping in both normal+visual to avoid overlap warnings
      comment = '<leader>/',
      comment_line = '<leader>/',
      comment_visual = '<leader>/',
      textobject = '',
    },
    options = {
      custom_commentstring = function()
        return require('ts_context_commentstring').calculate_commentstring() or vim.bo.commentstring
      end,
    },
   }
end)

-- auto-session (replaces mini.sessions)
now(function()
  add 'rmagatti/auto-session'
  
  require('auto-session').setup {
    auto_save = true,
    auto_restore = true,
    auto_create = true,
    suppressed_dirs = { '~/', '~/Downloads', '/' },
    bypass_save_filetypes = { 'alpha', 'dashboard' },
    session_lens = {
      load_on_setup = true,
    },
  }
  
  vim.keymap.set('n', '<leader>qs', '<cmd>AutoSession search<CR>', { desc = 'Search sessions' })
  vim.keymap.set('n', '<leader>Ss', '<cmd>AutoSession search<CR>', { desc = 'Search sessions' })
  vim.keymap.set('n', '<leader>Sw', '<cmd>AutoSession save<CR>', { desc = 'Save session' })
  vim.keymap.set('n', '<leader>Sd', '<cmd>AutoSession delete<CR>', { desc = 'Delete session' })
end)

-- Snippets (LuaSnip)
later(function()
  add {
    source = 'L3MON4D3/LuaSnip',
    depends = { 'rafamadriz/friendly-snippets' },
  }

  local luasnip = require 'luasnip'

  -- Load friendly-snippets
  require('luasnip.loaders.from_vscode').lazy_load()

  -- Snippet navigation keymaps
  vim.keymap.set({ 'i', 's' }, '<C-k>', function()
    if luasnip.expand_or_jumpable() then
      luasnip.expand_or_jump()
    end
  end, { desc = 'Expand or jump snippet' })

  vim.keymap.set({ 'i', 's' }, '<C-j>', function()
    if luasnip.jumpable(-1) then
      luasnip.jump(-1)
    end
  end, { desc = 'Jump snippet backward' })

  vim.keymap.set({ 'i', 's' }, '<C-l>', function()
    if luasnip.choice_active() then
      luasnip.change_choice(1)
    end
  end, { desc = 'Change snippet choice' })

  -- Integrate with blink.cmp
  luasnip.config.setup {
    history = true,
    updateevents = 'TextChanged,TextChangedI',
  }
end)

-- Auto-save
later(function()
  add 'okuuva/auto-save.nvim'
  
  require('auto-save').setup {
    enabled = true,
    trigger_events = {
      immediate_save = { 'BufLeave', 'FocusLost', 'QuitPre' },
      defer_save = { 'InsertLeave', 'TextChanged' },
      cancel_deferred_save = { 'InsertEnter' },
    },
    debounce_delay = 1000,
    condition = function(buf)
      local excluded = {
        'gitcommit', 'gitrebase',
        'NvimTree', 'neo-tree', 'MiniFiles',
        'TelescopePrompt', 'FzfLua',
        'alpha', 'dashboard',
        'toggleterm', 'terminal',
      }
      local ft = vim.fn.getbufvar(buf, '&filetype')
      
      -- Don't auto-save if filetype is excluded
      if vim.tbl_contains(excluded, ft) then
        return false
      end
      
      -- Don't auto-save if file doesn't have a name
      local filename = vim.fn.bufname(buf)
      if filename == '' then
        return false
      end
      
      return true
    end,
  }
  
  vim.keymap.set('n', '<leader>as', '<cmd>ASToggle<CR>', { desc = 'Toggle auto-save' })
end)

-- Flash.nvim (leap-style motion)
later(function()
  add 'folke/flash.nvim'

  require('flash').setup {
    modes = {
      char = {
        enabled = false, -- Disable in favor of default f/t
      },
    },
  }

  vim.keymap.set({ 'n', 'x', 'o' }, 'gj', function()
    require('flash').jump()
  end, { desc = 'Flash jump' })

  vim.keymap.set({ 'n', 'x', 'o' }, 'gJ', function()
    require('flash').treesitter()
  end, { desc = 'Flash treesitter' })
end)

-- ts_context_commentstring for better comment detection
later(function()
  add 'JoosepAlviste/nvim-ts-context-commentstring'

  require('ts_context_commentstring').setup {
    enable_autocmd = false,
  }
end)

-- Refactoring.nvim
later(function()
  add {
    source = 'ThePrimeagen/refactoring.nvim',
    depends = { 'nvim-lua/plenary.nvim', 'nvim-treesitter/nvim-treesitter' },
  }

  require('refactoring').setup {}

  -- Refactoring keymaps
  vim.keymap.set('x', '<leader>re', function()
    require('refactoring').refactor 'Extract Function'
  end, { desc = 'Extract function' })

  vim.keymap.set('x', '<leader>rf', function()
    require('refactoring').refactor 'Extract Function To File'
  end, { desc = 'Extract function to file' })

  vim.keymap.set('x', '<leader>rv', function()
    require('refactoring').refactor 'Extract Variable'
  end, { desc = 'Extract variable' })

  vim.keymap.set('n', '<leader>rI', function()
    require('refactoring').refactor 'Inline Function'
  end, { desc = 'Inline function' })

  vim.keymap.set({ 'n', 'x' }, '<leader>ri', function()
    require('refactoring').refactor 'Inline Variable'
  end, { desc = 'Inline variable' })

  vim.keymap.set('n', '<leader>rb', function()
    require('refactoring').refactor 'Extract Block'
  end, { desc = 'Extract block' })

  vim.keymap.set('n', '<leader>rB', function()
    require('refactoring').refactor 'Extract Block To File'
  end, { desc = 'Extract block to file' })

  -- Prompt for refactor
  vim.keymap.set({ 'n', 'x' }, '<leader>rr', function()
    require('refactoring').select_refactor()
  end, { desc = 'Select refactor' })
end)
