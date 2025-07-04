-- Define global options and variables early
vim.g.base46_cache = vim.fn.stdpath('data') .. '/base46_cache/'
vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'

-- Load core Neovim configurations
require('config.options')  -- Options and settings
require('config.autocmds') -- Auto commands

-- Bootstrap lazy.nvim and load plugins
require('config.lazy')

-- Load keymaps after plugins to ensure all plugin-specific mappings work
require('config.keymaps')  -- Key mappings

-- Load cached theme data
for _, v in ipairs(vim.fn.readdir(vim.g.base46_cache)) do
  dofile(vim.g.base46_cache .. v)
end
