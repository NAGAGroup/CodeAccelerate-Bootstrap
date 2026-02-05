-- Neovim 0.11.x Configuration
-- Bootstrap mini.deps and load core modules

vim.g.base46_cache = vim.fn.stdpath("data") .. "/base46_cache/"

-- Set leader keys before any mappings
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Bootstrap mini.deps
local path_package = vim.fn.stdpath("data") .. "/site/"
local mini_path = path_package .. "pack/deps/start/mini.nvim"

if not vim.loop.fs_stat(mini_path) then
	vim.cmd('echo "Installing mini.nvim" | redraw')
	local clone_cmd = { "git", "clone", "--filter=blob:none", "https://github.com/echasnovski/mini.nvim", mini_path }
	vim.fn.system(clone_cmd)
	vim.cmd("packadd mini.nvim | helptags ALL")
	vim.cmd('echo "Installed mini.nvim" | redraw')
end

-- Set up mini.deps
require("mini.deps").setup({ path = { package = path_package } })

-- Load core configuration modules
require("core.options")
require("core.keymaps")
require("core.autocmds")
require("core.diagnostics")

-- Load plugins (this will setup mini.deps add/now/later)
require("plugins.init")

-- Load LSP, formatting, linting after plugins are added
require("core.lsp")
require("core.formatting")
require("core.linting")
require("core.tools")

-- Load base46 theme cache (must be after plugins are loaded)
for _, v in ipairs(vim.fn.readdir(vim.g.base46_cache)) do
	dofile(vim.g.base46_cache .. v)
end
