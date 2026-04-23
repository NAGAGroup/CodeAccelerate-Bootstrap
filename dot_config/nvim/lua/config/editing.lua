-- =============================================================================
-- ts-context-commentstring — smart comment strings per filetype
-- =============================================================================
-- enable_autocmd = false: disable background autocmd; calculation is manual only
-- (called explicitly by mini.comment's custom_commentstring callback)
require('ts_context_commentstring').setup({
  enable_autocmd = false,
})

-- =============================================================================
-- mini.pairs — autopairs
-- =============================================================================
require('mini.pairs').setup({})

-- =============================================================================
-- mini.ai — enhanced text objects
-- =============================================================================
require('mini.ai').setup({})

-- =============================================================================
-- mini.surround — gs prefix for surround operations
-- =============================================================================
require('mini.surround').setup({
  mappings = {
    add            = 'gsa',
    delete         = 'gsd',
    find           = 'gsf',
    find_left      = 'gsF',
    highlight      = 'gsh',
    replace        = 'gsr',
    suffix_last    = 'l',
    suffix_next    = 'n',
  },
})

-- =============================================================================
-- mini.comment — gc/gcc with ts-context-commentstring integration
-- =============================================================================
require('mini.comment').setup({
  options = {
    -- Use ts-context-commentstring for filetype-aware comment strings
    -- Falls back to vim.bo.commentstring if not available
    custom_commentstring = function()
      return require('ts_context_commentstring').calculate_commentstring()
        or vim.bo.commentstring
    end,
  },
})

-- =============================================================================
-- mini.move — Alt+hjkl for moving lines and selections
-- =============================================================================
require('mini.move').setup({
  mappings = {
    left       = '<M-h>',
    right      = '<M-l>',
    down       = '<M-j>',
    up         = '<M-k>',
    line_left  = '<M-h>',
    line_right = '<M-l>',
    line_down  = '<M-j>',
    line_up    = '<M-k>',
  },
})

-- =============================================================================
-- flash.nvim — smart jump motion with s/S
-- =============================================================================
require('flash').setup({
  modes = {
    char = { enabled = false },  -- Disable f/F/t/T interception; use native Vim char motions
  },
})

-- s: jump to location (2-char input) in normal/visual/operator modes
vim.keymap.set({ 'n', 'x', 'o' }, 's', function() require('flash').jump() end,
  { desc = 'Flash: jump' })

-- S: jump using treesitter node selection
vim.keymap.set({ 'n', 'x', 'o' }, 'S', function() require('flash').treesitter() end,
  { desc = 'Flash: treesitter jump' })

-- =============================================================================
-- refactoring.nvim — code refactoring operations (setup() not required)
-- =============================================================================
local r = require('refactoring')

vim.keymap.set({ 'n', 'x' }, '<leader>re',
  function() return r.extract_func() end,
  { expr = true, desc = 'Refactor: extract function' })

vim.keymap.set({ 'n', 'x' }, '<leader>rf',
  function() return r.extract_func_to_file() end,
  { expr = true, desc = 'Refactor: extract function to file' })

vim.keymap.set({ 'n', 'x' }, '<leader>rv',
  function() return r.extract_var() end,
  { expr = true, desc = 'Refactor: extract variable' })

vim.keymap.set({ 'n', 'x' }, '<leader>rI',
  function() return r.inline_func() end,
  { expr = true, desc = 'Refactor: inline function' })

vim.keymap.set({ 'n', 'x' }, '<leader>ri',
  function() return r.inline_var() end,
  { expr = true, desc = 'Refactor: inline variable' })

vim.keymap.set({ 'n', 'x' }, '<leader>rs',
  function() return r.select_refactor() end,
  { expr = true, desc = 'Refactor: select refactor' })

-- =============================================================================
-- todo-comments.nvim — TODO/FIXME/NOTE highlighting and navigation
-- =============================================================================
require('todo-comments').setup({})

-- Navigation keymaps — NOT auto-created; must be defined manually
vim.keymap.set('n', ']t', function() require('todo-comments').jump_next() end,
  { desc = 'Next TODO comment' })
vim.keymap.set('n', '[t', function() require('todo-comments').jump_prev() end,
  { desc = 'Previous TODO comment' })

-- Quickfix list
vim.keymap.set('n', '<leader>ft', '<cmd>TodoQuickFix<cr>',
  { desc = 'TODOs in quickfix' })

-- Trouble integration (trouble v3 command syntax)
vim.keymap.set('n', '<leader>xt', '<cmd>Trouble todo toggle<cr>',
  { desc = 'TODOs in Trouble' })
vim.keymap.set('n', '<leader>xT', '<cmd>Trouble todo toggle filter={tag={TODO,FIX,FIXME}}<cr>',
  { desc = 'FIX/FIXME/TODO in Trouble' })

-- =============================================================================
-- persistence.nvim — session management
-- =============================================================================
require('persistence').setup({
  dir = vim.fn.stdpath('state') .. '/sessions/',
  branch = false,  -- don't append git branch to session name
})

vim.keymap.set('n', '<leader>qs', function() require('persistence').select() end,
  { desc = 'Session: select' })
vim.keymap.set('n', '<leader>ql', function() require('persistence').load() end,
  { desc = 'Session: restore (cwd)' })
vim.keymap.set('n', '<leader>qS', function() require('persistence').load({ last = true }) end,
  { desc = 'Session: restore last' })
vim.keymap.set('n', '<leader>qd', function() require('persistence').stop() end,
  { desc = "Session: don't save on exit" })
