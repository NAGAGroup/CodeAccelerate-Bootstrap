-- Neovim options configuration
-- This file configures Vim/Neovim options and variables

------------------
-- Global Variables
------------------
-- base46 cache directory
vim.g.base46_cache = vim.fn.stdpath 'data' .. '/base46_cache/'

-- Leader keys
vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'
-- Plugin-specific settings
vim.g.snacks_animate = true -- Enable snacks animations
vim.g.ai_cmp = true -- Use AI source when completion engine supports it
vim.g.trouble_lualine = true -- Show document symbols in lualine
vim.g.deprecation_warnings = false -- Hide deprecation warnings

-- Project root detection
vim.g.root_spec = { 'lsp', { '.git', 'lua' }, 'cwd' }
vim.g.root_lsp_ignore = { 'copilot' }

-- Fix markdown indentation settings
vim.g.markdown_recommended_style = 0

------------------
-- Editor Options
------------------
local opt = vim.opt

-- General behavior
opt.autowrite = true -- Auto save before commands like :next and :make
opt.confirm = true -- Confirm changes before exiting modified buffer
opt.mouse = 'a' -- Enable mouse in all modes
opt.updatetime = 200 -- Faster completion and better UX
opt.timeoutlen = vim.g.vscode and 1000 or 300 -- Key sequence timeout
opt.virtualedit = 'block' -- Allow cursor beyond text in visual block mode
opt.wildmode = 'longest:full,full' -- Command completion mode
opt.jumpoptions = 'view' -- Keep view when jumping to marks/tags

-- Visual display
opt.cursorline = true -- Highlight current line
opt.laststatus = 3 -- Global statusline
opt.list = true -- Show some invisible characters
opt.number = true -- Show line numbers
opt.relativenumber = true -- Show relative line numbers
opt.ruler = false -- Hide default ruler (using statusline)
opt.showmode = false -- Hide mode indicator (using statusline)
opt.signcolumn = 'yes' -- Always show the sign column
opt.statuscolumn = [[%!v:lua.require'snacks.statuscolumn'.get()]]
opt.termguicolors = true -- True color support

-- UI appearance
opt.conceallevel = 2 -- Hide markup in markdown, but not substitutions
opt.pumblend = 10 -- Popup menu transparency
opt.pumheight = 10 -- Maximum popup menu height
opt.scrolloff = 4 -- Lines of context when scrolling
opt.sidescrolloff = 8 -- Columns of context when scrolling
opt.shortmess:append { W = true, I = true, c = true, C = true } -- Reduce messages
opt.winminwidth = 5 -- Minimum window width

-- Indentation and text display
opt.expandtab = true -- Use spaces instead of tabs
opt.formatoptions = 'jcroqlnt' -- Text formatting options
opt.linebreak = true -- Wrap lines at word boundaries
opt.shiftround = true -- Round indent to shiftwidth multiple
opt.shiftwidth = 2 -- Size of an indent
opt.smartcase = true -- Smart case sensitivity in search
opt.smartindent = true -- Smart indentation
opt.spelllang = { 'en' } -- English spellcheck
opt.tabstop = 2 -- Tab size
opt.wrap = false -- Don't wrap lines

-- Window management
opt.splitbelow = true -- New splits below current window
opt.splitkeep = 'screen' -- Keep screen position when splitting
opt.splitright = true -- New splits to the right

-- Search and replace
opt.grepformat = '%f:%l:%c:%m' -- Grep output format
opt.grepprg = 'rg --vimgrep' -- Use ripgrep for grepping
opt.ignorecase = true -- Case insensitive search
opt.inccommand = 'nosplit' -- Preview incremental substitute

-- Undo and history
opt.undofile = true -- Persistent undo
opt.undolevels = 10000 -- Maximum undo levels

-- Special characters
opt.fillchars = {
  foldopen = '',
  foldclose = '',
  fold = ' ',
  foldsep = ' ',
  diff = '╱',
  eob = ' ',
}

-- Session options
opt.sessionoptions = {
  'buffers',
  'curdir',
  'tabpages',
  'winsize',
  'help',
  'globals',
  'skiprtp',
  'folds',
}

-- Completion menu
opt.completeopt = 'menu,menuone,noselect'

-- Folding options
opt.smoothscroll = true -- Smooth scrolling
opt.foldmethod = 'expr' -- Use expression for folding
opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()' -- Use built-in treesitter folding
opt.foldtext = '' -- Custom fold text
opt.foldlevel = 99 -- Start with all folds open
opt.foldlevelstart = 99 -- Start with all folds open

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
opt.clipboard = vim.env.SSH_TTY and '' or 'unnamedplus'
