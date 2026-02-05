-- Core autocommands

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- Highlight on yank
autocmd('TextYankPost', {
  group = augroup('highlight_yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank { timeout = 200 }
  end,
})

-- Close some filetypes with q
autocmd('FileType', {
  group = augroup('close_with_q', { clear = true }),
  pattern = { 'help', 'man', 'qf', 'notify', 'checkhealth' },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set('n', 'q', '<cmd>close<CR>', { buffer = event.buf, silent = true })
  end,
})

-- Check if file changed outside of vim
autocmd({ 'FocusGained', 'TermClose', 'TermLeave' }, {
  group = augroup('checktime', { clear = true }),
  command = 'checktime',
})

-- Resize splits if window got resized
autocmd('VimResized', {
  group = augroup('resize_splits', { clear = true }),
  callback = function()
    vim.cmd 'tabdo wincmd ='
  end,
})

-- Remove trailing whitespace on save
autocmd('BufWritePre', {
  group = augroup('trim_whitespace', { clear = true }),
  pattern = '*',
  callback = function()
    local save_cursor = vim.fn.getpos '.'
    vim.cmd [[%s/\s\+$//e]]
    vim.fn.setpos('.', save_cursor)
  end,
})

-- Set wrap and spell for text filetypes
autocmd('FileType', {
  group = augroup('wrap_spell', { clear = true }),
  pattern = { 'gitcommit', 'markdown', 'text' },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})
