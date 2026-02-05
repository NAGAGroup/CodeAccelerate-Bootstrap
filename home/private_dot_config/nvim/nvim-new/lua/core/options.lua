-- Core Neovim options

local opt = vim.opt

-- Line numbers
opt.number = true
opt.relativenumber = true

-- Indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.smartindent = true

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- UI
opt.termguicolors = true
opt.signcolumn = 'yes'
opt.cursorline = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.wrap = false

-- Editing
opt.mouse = 'a'
opt.undofile = true
opt.backup = false
opt.writebackup = false
opt.swapfile = false

-- Clipboard configuration for OSC52 (for remote SSH sessions)
vim.g.clipboard = {
  name = 'OSC 52',
  copy = {
    ['+'] = require('vim.ui.clipboard.osc52').copy '+',
    ['*'] = require('vim.ui.clipboard.osc52').copy '*',
  },
  paste = {
    ['+'] = require('vim.ui.clipboard.osc52').paste '+',
    ['*'] = require('vim.ui.clipboard.osc52').paste '*',
  },
}

-- Set clipboard based on SSH status
-- In SSH sessions, use OSC52, otherwise sync with system clipboard
opt.clipboard = ''

-- Completion
opt.completeopt = 'menu,menuone,noselect'

-- Split windows
opt.splitright = true
opt.splitbelow = true

-- Update time
opt.updatetime = 250
opt.timeoutlen = 300

-- Show whitespace
opt.list = true
opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Folding (use treesitter when available)
opt.foldmethod = 'expr'
opt.foldexpr = 'nvim_treesitter#foldexpr()'
opt.foldenable = false -- Start with folds open

-- Base46 cache directory (for NvChad theming)
vim.g.base46_cache = vim.fn.stdpath 'data' .. '/base46_cache/'
