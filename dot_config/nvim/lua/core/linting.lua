-- Linting via nvim-lint

local add = MiniDeps.add
add 'mfussenegger/nvim-lint'

local lint = require 'lint'

lint.linters_by_ft = {
  -- Python
  python = { 'ruff' },

  -- Shell
  bash = { 'shellcheck' },
  sh = { 'shellcheck' },
}

-- Auto-lint on save and text change
-- vim.schedule avoids blocking the save event (prevents hang on :w)
-- vim.g.linting_enabled is controlled by core/toggles.lua
vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufReadPost', 'InsertLeave' }, {
  group = vim.api.nvim_create_augroup('nvim_lint', { clear = true }),
  callback = function()
    if vim.g.linting_enabled == false then return end
    vim.schedule(function()
      lint.try_lint()
    end)
  end,
})
