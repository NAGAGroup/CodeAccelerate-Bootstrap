-- Base46 Theming Stuffs
vim.g.base46_cache = vim.fn.stdpath("data") .. "/base46_cache/"
local path = vim.g.base46_cache
if vim.fn.isdirectory(path) == 0 then
	vim.fn.mkdir(path, "p") -- "p" creates intermediate directories if needed
end

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- More Base46 Theming Stuffs
require("base46").load_all_highlights()
dofile(vim.g.base46_cache .. "syntax")
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")
dofile(vim.g.base46_cache .. "treesitter")
dofile(vim.g.base46_cache .. "nvimtree")
dofile(vim.g.base46_cache .. "cmp")
dofile(vim.g.base46_cache .. "trouble")
dofile(vim.g.base46_cache .. "dap")
require("base46").load_all_highlights()
