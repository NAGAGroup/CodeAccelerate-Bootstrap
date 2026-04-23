-- =============================================================================
-- toggles.lua — Feature toggle system
-- =============================================================================

-- Initialize global toggle state
vim.g.disable_autoformat = false   -- Global format-on-save toggle (false = enabled)
vim.g.lint_disabled       = false   -- Global lint toggle (false = enabled)

-- =============================================================================
-- Format toggles
-- =============================================================================

-- leader-uf: Toggle format-on-save globally
vim.keymap.set('n', '<leader>uf', function()
  vim.g.disable_autoformat = not vim.g.disable_autoformat
  if vim.g.disable_autoformat then
    vim.notify('Format on save: DISABLED (global)', vim.log.levels.WARN)
  else
    vim.notify('Format on save: ENABLED (global)', vim.log.levels.INFO)
  end
end, { desc = 'Toggle: format on save (global)' })

-- leader-uF: Toggle format-on-save for current buffer only
vim.keymap.set('n', '<leader>uF', function()
  local bufnr = vim.api.nvim_get_current_buf()
  vim.b[bufnr].disable_autoformat = not vim.b[bufnr].disable_autoformat
  if vim.b[bufnr].disable_autoformat then
    vim.notify('Format on save: DISABLED (buffer)', vim.log.levels.WARN)
  else
    vim.notify('Format on save: ENABLED (buffer)', vim.log.levels.INFO)
  end
end, { desc = 'Toggle: format on save (buffer)' })

-- =============================================================================
-- Lint toggle
-- =============================================================================

-- leader-ul: Toggle linting
vim.keymap.set('n', '<leader>ul', function()
  vim.g.lint_disabled = not vim.g.lint_disabled
  if vim.g.lint_disabled then
    vim.notify('Linting: DISABLED', vim.log.levels.WARN)
  else
    vim.notify('Linting: ENABLED', vim.log.levels.INFO)
  end
end, { desc = 'Toggle: linting' })

-- =============================================================================
-- Diagnostic toggle
-- =============================================================================

-- leader-ud: Toggle diagnostics (virtual text, signs, underline)
vim.keymap.set('n', '<leader>ud', function()
  local cfg = vim.diagnostic.config()
  local enabled = cfg and cfg.virtual_text ~= false
  vim.diagnostic.config({
    virtual_text = not enabled,
    signs        = not enabled,
    underline    = not enabled,
  })
  vim.notify('Diagnostics: ' .. (not enabled and 'ENABLED' or 'DISABLED'), vim.log.levels.INFO)
end, { desc = 'Toggle: diagnostics display' })

-- =============================================================================
-- Other UI toggles
-- =============================================================================

-- leader-ui: Toggle LSP inlay hints
vim.keymap.set('n', '<leader>ui', function()
  local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = 0 })
  vim.lsp.inlay_hint.enable(not enabled, { bufnr = 0 })
  vim.notify('Inlay hints: ' .. (not enabled and 'ENABLED' or 'DISABLED'), vim.log.levels.INFO)
end, { desc = 'Toggle: LSP inlay hints' })

-- leader-us: Toggle spell check
vim.keymap.set('n', '<leader>us', function()
  vim.opt_local.spell = not vim.opt_local.spell:get()
  vim.notify('Spell check: ' .. (vim.opt_local.spell:get() and 'ENABLED' or 'DISABLED'), vim.log.levels.INFO)
end, { desc = 'Toggle: spell check' })

-- leader-uw: Toggle word wrap
vim.keymap.set('n', '<leader>uw', function()
  vim.opt_local.wrap = not vim.opt_local.wrap:get()
  vim.notify('Word wrap: ' .. (vim.opt_local.wrap:get() and 'ENABLED' or 'DISABLED'), vim.log.levels.INFO)
end, { desc = 'Toggle: word wrap' })

-- leader-un: Toggle relative line numbers
vim.keymap.set('n', '<leader>un', function()
  vim.opt.relativenumber = not vim.opt.relativenumber:get()
  vim.notify('Relative numbers: ' .. (vim.opt.relativenumber:get() and 'ENABLED' or 'DISABLED'), vim.log.levels.INFO)
end, { desc = 'Toggle: relative line numbers' })
