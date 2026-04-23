-- Neovim v0.12 autocommands configuration

-- Augroup: highlight_yank
-- Briefly highlight yanked text
local highlight_yank = vim.api.nvim_create_augroup('highlight_yank', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  group = highlight_yank,
  pattern = '*',
  callback = function()
    vim.highlight.on_yank({ timeout = 200 })
  end,
  desc = 'Briefly highlight yanked text',
})

-- Augroup: close_with_q
-- Close utility buffers with q
local close_with_q = vim.api.nvim_create_augroup('close_with_q', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
  group = close_with_q,
  pattern = { 'help', 'man', 'qf', 'notify', 'checkhealth' },
  callback = function(event)
    vim.opt_local.buflisted = false
    vim.keymap.set('n', 'q', ':close<CR>', { buffer = event.buf, silent = true, desc = 'Close window' })
  end,
  desc = 'Close utility buffers with q',
})

-- Augroup: checktime
-- Auto-reload file on focus regain
local checktime = vim.api.nvim_create_augroup('checktime', { clear = true })
vim.api.nvim_create_autocmd({ 'FocusGained', 'TermClose', 'TermLeave' }, {
  group = checktime,
  pattern = '*',
  command = ':checktime',
  desc = 'Auto-reload file on focus regain',
})

-- Augroup: resize_splits
-- Auto-resize splits on window resize
local resize_splits = vim.api.nvim_create_augroup('resize_splits', { clear = true })
vim.api.nvim_create_autocmd('VimResized', {
  group = resize_splits,
  pattern = '*',
  callback = function()
    vim.cmd('tabdo wincmd =')
  end,
  desc = 'Auto-resize splits on window resize',
})

-- Augroup: trim_whitespace
-- Strip trailing whitespace on save
local trim_whitespace = vim.api.nvim_create_augroup('trim_whitespace', { clear = true })
vim.api.nvim_create_autocmd('BufWritePre', {
  group = trim_whitespace,
  pattern = '*',
  callback = function()
    vim.cmd([[%s/\s\+$//e]])
  end,
  desc = 'Strip trailing whitespace on save',
})

-- Augroup: wrap_spell
-- Enable wrap and spell for prose filetypes
local wrap_spell = vim.api.nvim_create_augroup('wrap_spell', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
  group = wrap_spell,
  pattern = { 'gitcommit', 'markdown', 'text' },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
  desc = 'Enable wrap and spell for prose filetypes',
})

-- Augroup: dapui_statusline
-- Hide statusline in DAP UI panels
local dapui_statusline = vim.api.nvim_create_augroup('dapui_statusline', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
  group = dapui_statusline,
  pattern = { 'dapui_scopes', 'dapui_breakpoints', 'dapui_stacks', 'dapui_watches', 'dapui_console', 'dap-repl' },
  callback = function()
    vim.opt_local.laststatus = 0
  end,
  desc = 'Hide statusline in DAP UI panels',
})

-- Augroup: treesitter_folds
-- Workaround for Neovim #28692 — force treesitter fold recomputation after parser attaches
-- TODO: remove when https://github.com/neovim/neovim/issues/28692 is confirmed fixed
local treesitter_folds = vim.api.nvim_create_augroup('treesitter_folds', { clear = true })
vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufNewFile' }, {
  group = treesitter_folds,
  pattern = '*',
  callback = function()
    vim.schedule(function()
      vim.cmd('normal! zx')
    end)
  end,
  desc = 'Workaround for Neovim #28692 — force treesitter fold recomputation after parser attaches',
})
