-- =============================================================================
-- diagnostics.lua — Diagnostic display configuration
-- =============================================================================

-- Configure diagnostic display
-- NOTE: signs use vim.diagnostic.severity enum keys (NOT string keys) in v0.12
vim.diagnostic.config({
  virtual_text = {
    spacing = 4,
    prefix  = '●',
    source  = 'if_many',
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = '',
      [vim.diagnostic.severity.WARN]  = '',
      [vim.diagnostic.severity.HINT]  = '',
      [vim.diagnostic.severity.INFO]  = '',
    },
  },
  underline     = true,
  severity_sort = true,
  float = {
    focus  = false,
    scope  = 'cursor',
    border = 'rounded',
  },
})

-- Show diagnostic float on cursor hold
-- (updatetime=250 is already set in options.lua)
vim.api.nvim_create_autocmd('CursorHold', {
  callback = function()
    vim.diagnostic.open_float(nil, { scope = 'cursor', focus = false })
  end,
  desc = 'Show diagnostic float on cursor hold',
})

-- Diagnostic navigation keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Diagnostic: go to previous' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Diagnostic: go to next' })
vim.keymap.set('n', '<leader>cd', vim.diagnostic.open_float, { desc = 'Diagnostic: show float' })
vim.keymap.set('n', '<leader>dl', vim.diagnostic.setloclist, { desc = 'Diagnostic: to loclist' })
