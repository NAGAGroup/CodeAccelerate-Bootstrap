--[[
  Neovim Autocommands Configuration
  
  This file contains all autocommands used in the Neovim configuration.
  Organized into logical sections for better maintainability.
]]

---------------------------------
-- Helper Functions
---------------------------------

-- Create augroup with consistent naming
local function augroup(name)
  return vim.api.nvim_create_augroup('nvim_' .. name, { clear = true })
end

---------------------------------
-- File Operations
---------------------------------

-- Check if file changed externally
vim.api.nvim_create_autocmd({ 'FocusGained', 'TermClose', 'TermLeave' }, {
  group = augroup 'checktime',
  desc = 'Check if buffer changed when cursor returns to Neovim',
  callback = function()
    if vim.o.buftype ~= 'nofile' then
      vim.cmd 'checktime'
    end
  end,
})

-- Return to last edit position when opening files
vim.api.nvim_create_autocmd('BufReadPost', {
  group = augroup 'last_position',
  desc = 'Return to last edit position when opening files',
  callback = function(event)
    local exclude = { 'gitcommit' }
    local buf = event.buf

    -- Skip excluded filetypes or buffers where this was already done
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].nvim_last_position then
      return
    end

    vim.b[buf].nvim_last_position = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)

    -- Make sure the mark position exists in the file
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Auto create directory when saving a file if directory doesn't exist
vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
  group = augroup 'auto_create_dir',
  desc = 'Auto create directory when saving a file',
  callback = function(event)
    -- Skip URLs
    if event.match:match '^%w%w+:[\\/][\\/]' then
      return
    end

    -- Create directory if it doesn't exist
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ':p:h'), 'p')
  end,
})

---------------------------------
-- UI Enhancements
---------------------------------

-- Highlight text on yank
vim.api.nvim_create_autocmd('TextYankPost', {
  group = augroup 'highlight_yank',
  desc = 'Highlight yanked text briefly',
  callback = function()
    (vim.hl or vim.highlight).on_yank()
  end,
})

-- Resize splits if window size changes
vim.api.nvim_create_autocmd({ 'VimResized' }, {
  group = augroup 'resize_splits',
  desc = 'Resize splits when terminal is resized',
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd 'tabdo wincmd ='
    vim.cmd('tabnext ' .. current_tab)
  end,
})

---------------------------------
-- Filetype-Specific Settings
---------------------------------

-- Close special buffers with q key
vim.api.nvim_create_autocmd('FileType', {
  group = augroup 'close_with_q',
  desc = 'Close special buffers with q key',
  pattern = {
    'PlenaryTestPopup',
    'checkhealth',
    'dbout',
    'gitsigns-blame',
    'grug-far',
    'help',
    'lspinfo',
    'neotest-output',
    'neotest-output-panel',
    'neotest-summary',
    'notify',
    'qf',
    'spectre_panel',
    'startuptime',
    'tsplayground',
  },
  callback = function(event)
    -- Mark buffer as not listed and map q to close
    vim.bo[event.buf].buflisted = false
    vim.schedule(function()
      vim.keymap.set('n', 'q', function()
        vim.cmd 'close'
        pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
      end, {
        buffer = event.buf,
        silent = true,
        desc = 'Close buffer',
      })
    end)
  end,
})

-- Mark man pages as unlisted
vim.api.nvim_create_autocmd('FileType', {
  group = augroup 'man_unlisted',
  desc = 'Mark man pages as unlisted in buffer list',
  pattern = { 'man' },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
  end,
})

-- Enable wrap and spell check for text filetypes
vim.api.nvim_create_autocmd('FileType', {
  group = augroup 'wrap_spell',
  desc = 'Enable wrap and spell check for text filetypes',
  pattern = { 'text', 'plaintex', 'typst', 'gitcommit', 'markdown' },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- Disable conceallevel for JSON files
vim.api.nvim_create_autocmd({ 'FileType' }, {
  group = augroup 'json_conceal',
  desc = 'Disable conceallevel for JSON files',
  pattern = { 'json', 'jsonc', 'json5' },
  callback = function()
    vim.opt_local.conceallevel = 0
  end,
})
