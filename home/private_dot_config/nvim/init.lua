-- Base46 Theming Stuffs
vim.g.base46_cache = vim.fn.stdpath("data") .. "/base46_cache/"
local path = vim.g.base46_cache
if vim.fn.isdirectory(path) == 0 then
	vim.fn.mkdir(path, "p") -- "p" creates intermediate directories if needed
end

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- More Base46 Theming Stuffs
local function add_highlight(highlight)
	if vim.fn.filereadable(highlight) ~= 0 then
		dofile(highlight)
	end
end
add_highlight(vim.g.base46_cache .. "defaults")
add_highlight(vim.g.base46_cache .. "statusline")
add_highlight(vim.g.base46_cache .. "treesitter")
add_highlight(vim.g.base46_cache .. "nvimtree")
add_highlight(vim.g.base46_cache .. "cmp")
add_highlight(vim.g.base46_cache .. "trouble")
add_highlight(vim.g.base46_cache .. "dap")

require("base46").load_all_highlights()
