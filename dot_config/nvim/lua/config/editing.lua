-- =============================================================================
-- editing.lua — mini.* + ts-comments + todo-comments + refactor + grug-far + dial
-- =============================================================================

require("mini.pairs").setup({})
require("mini.ai").setup({})
require("mini.surround").setup({
	mappings = {
		add = "gsa",
		delete = "gsd",
		find = "gsf",
		find_left = "gsF",
		highlight = "gsh",
		replace = "gsr",
		suffix_last = "l",
		suffix_next = "n",
	},
})
require("mini.move").setup({
	mappings = {
		left = "<M-h>",
		right = "<M-l>",
		down = "<M-j>",
		up = "<M-k>",
		line_left = "<M-h>",
		line_right = "<M-l>",
		line_down = "<M-j>",
		line_up = "<M-k>",
	},
})

-- ts-comments (no setup needed — auto-configures on load)

-- todo-comments
require("todo-comments").setup({})
vim.keymap.set("n", "]t", function()
	require("todo-comments").jump_next()
end, { desc = "Next TODO" })
vim.keymap.set("n", "[t", function()
	require("todo-comments").jump_prev()
end, { desc = "Prev TODO" })

-- refactoring
local r = require("refactoring")
vim.keymap.set({ "n", "x" }, "<leader>re", function()
	return r.extract_func()
end, { expr = true, desc = "Refactor: extract function" })
vim.keymap.set({ "n", "x" }, "<leader>rf", function()
	return r.extract_func_to_file()
end, { expr = true, desc = "Refactor: extract to file" })
vim.keymap.set({ "n", "x" }, "<leader>rv", function()
	return r.extract_var()
end, { expr = true, desc = "Refactor: extract variable" })
vim.keymap.set({ "n", "x" }, "<leader>ri", function()
	return r.inline_var()
end, { expr = true, desc = "Refactor: inline variable" })
vim.keymap.set({ "n", "x" }, "<leader>rs", function()
	return r.select_refactor()
end, { expr = true, desc = "Refactor: select" })

-- grug-far
require("grug-far").setup({})

-- dial
local dial = require("dial")
vim.keymap.set("n", "<C-a>", function()
	dial.manipulate("increment", "normal")
end, { desc = "Increment" })
vim.keymap.set("n", "<C-x>", function()
	dial.manipulate("decrement", "normal")
end, { desc = "Decrement" })
vim.keymap.set("n", "g<C-a>", function()
	dial.manipulate("increment", "gnormal")
end, { desc = "Increment (all)" })
vim.keymap.set("n", "g<C-x>", function()
	dial.manipulate("decrement", "gnormal")
end, { desc = "Decrement (all)" })
vim.keymap.set("v", "<C-a>", function()
	dial.manipulate("increment", "visual")
end, { desc = "Increment" })
vim.keymap.set("v", "<C-x>", function()
	dial.manipulate("decrement", "visual")
end, { desc = "Decrement" })
vim.keymap.set("v", "g<C-a>", function()
	dial.manipulate("increment", "gvisual")
end, { desc = "Increment (all)" })
vim.keymap.set("v", "g<C-x>", function()
	dial.manipulate("decrement", "gvisual")
end, { desc = "Decrement (all)" })

-- snacks.words — auto-mapped by snacks when enabled (]]/[[/<a-n>/<a-p>)
