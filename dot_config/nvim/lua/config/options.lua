-- Neovim v0.12 core options configuration

-- Leader Keys
-- Note: vim.g.mapleader and vim.g.maplocalleader are set in init.lua
-- They must be set before vim.pack.add() — do not set them here

-- Editor Options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.termguicolors = true
vim.opt.signcolumn = 'yes'
vim.opt.cursorline = true
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.wrap = false
vim.opt.mouse = 'a'
vim.opt.undofile = true
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false
vim.opt.completeopt = 'menu,menuone,noselect'
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.confirm = true

-- Shell
local bash = vim.fn.exepath('bash')
if bash ~= '' then
  vim.opt.shell = bash
else
  vim.notify('bash not found; shell not set', vim.log.levels.WARN)
end

-- Folding
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.opt.foldenable = true
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldcolumn = '1'

-- Global Settings
vim.o.winborder = 'rounded'
vim.o.sessionoptions = 'buffers,curdir,folds,help,tabpages,winsize,globals'

-- Clipboard (OSC52 — SSH compatible)
-- OSC52 clipboard: works over SSH and in local terminals
-- v0.12 auto-detects OSC52 in SSH ($SSH_TTY set, $TMUX unset)
-- Explicit config ensures it works in all terminal environments
vim.g.clipboard = {
  name = 'OSC 52',
  copy = {
    ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
    ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
  },
  paste = {
    ['+'] = require('vim.ui.clipboard.osc52').paste('+'),
    ['*'] = require('vim.ui.clipboard.osc52').paste('*'),
  },
}
