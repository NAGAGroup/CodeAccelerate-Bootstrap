-- =============================================================================
-- linting.lua — Async linting via nvim-lint
-- =============================================================================

-- Configure linters by filetype
-- NOTE: nvim-lint has NO setup() function — direct table assignment only
require('lint').linters_by_ft = {
  python = { 'ruff' },
  sh     = { 'shellcheck' },
  bash   = { 'shellcheck' },
}

-- Register lint triggers on write/read/leave insert
-- try_lint() is itself async; vim.schedule() added for belt-and-suspenders safety
vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufReadPost', 'InsertLeave' }, {
  group    = vim.api.nvim_create_augroup('nvim_lint', { clear = true }),
  callback = function()
    -- Gate on toggle flag
    if vim.g.lint_disabled then return end
    vim.schedule(function()
      require('lint').try_lint()
    end)
  end,
  desc = 'Run nvim-lint on buffer events',
})
