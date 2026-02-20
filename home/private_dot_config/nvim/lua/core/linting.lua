-- Linting via nvim-lint

local add = MiniDeps.add
add 'mfussenegger/nvim-lint'

local lint = require 'lint'

lint.linters_by_ft = {
  -- Python
  python = { 'ruff' },

  -- JavaScript/TypeScript
  javascript = { 'biome' },
  typescript = { 'biome' },
  javascriptreact = { 'biome' },
  typescriptreact = { 'biome' },

  -- Shell
  bash = { 'shellcheck' },
  sh = { 'shellcheck' },
}

-- Auto-lint on save and text change
vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufReadPost', 'InsertLeave' }, {
  group = vim.api.nvim_create_augroup('nvim_lint', { clear = true }),
  callback = function()
    lint.try_lint()
  end,
})
