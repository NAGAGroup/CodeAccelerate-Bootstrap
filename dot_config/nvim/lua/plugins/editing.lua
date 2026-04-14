-- Editing helpers

local add = MiniDeps.add

-- mini.pairs (autopairs)
require("mini.pairs").setup()

-- mini.surround (gs prefix — avoids conflict with flash.nvim's s/S, matches LazyVim muscle memory)
require("mini.surround").setup({
	mappings = {
		add = "gsa",
		delete = "gsd",
		find = "gsf",
		find_left = "gsF",
		highlight = "gsh",
		replace = "gsr",
		update_n_lines = "gsn",
	},
})

-- mini.comment (gc/gcc — LazyVim standard, vim-commentary compatible muscle memory)
require("mini.comment").setup({
	mappings = {
		comment = "gc",
		comment_line = "gcc",
		comment_visual = "gc",
		textobject = "gc",
	},
	options = {
		custom_commentstring = function()
			return require("ts_context_commentstring").calculate_commentstring() or vim.bo.commentstring
		end,
	},
})

-- mini.ai: Enhanced text objects (a/i for arguments, quotes, brackets, etc.)
add("echasnovski/mini.ai")
require("mini.ai").setup({
	n_lines = 500,
	-- custom_textobjects can be added here if desired
})

-- mini.move: Move lines and selections with Alt+hjkl
add("echasnovski/mini.move")
require("mini.move").setup({
	-- Default keymaps: <M-h/j/k/l> in both normal and visual mode
	-- Moving selections left/right/up/down
})

-- persistence.nvim: LazyVim-style session management (explicit restore, no auto-restore on startup)
add("folke/persistence.nvim")
require("persistence").setup({
	dir = vim.fn.expand(vim.fn.stdpath("data") .. "/sessions/"),
})
local map = vim.keymap.set
map("n", "<leader>qs", function() require("persistence").select() end, { desc = "Select session" })
map("n", "<leader>ql", function() require("persistence").load() end, { desc = "Restore session (cwd)" })
map("n", "<leader>qS", function() require("persistence").load({ last = true }) end, { desc = "Restore last session" })
map("n", "<leader>qd", function() require("persistence").stop() end, { desc = "Don't save session" })

-- Snippets (LuaSnip)
add({
	source = "L3MON4D3/LuaSnip",
	depends = { "rafamadriz/friendly-snippets" },
})

local luasnip = require("luasnip")

-- Load friendly-snippets
require("luasnip.loaders.from_vscode").lazy_load()

-- Snippet navigation keymaps
vim.keymap.set({ "i", "s" }, "<C-k>", function()
	if luasnip.expand_or_jumpable() then
		luasnip.expand_or_jump()
	end
end, { desc = "Expand or jump snippet" })

vim.keymap.set({ "i", "s" }, "<C-j>", function()
	if luasnip.jumpable(-1) then
		luasnip.jump(-1)
	end
end, { desc = "Jump snippet backward" })

vim.keymap.set({ "i", "s" }, "<C-l>", function()
	if luasnip.choice_active() then
		luasnip.change_choice(1)
	end
end, { desc = "Change snippet choice" })

-- Integrate with blink.cmp
luasnip.config.setup({
	history = true,
	updateevents = "TextChanged,TextChangedI",
})

-- Flash.nvim (leap-style motion)
add("folke/flash.nvim")

require("flash").setup({
	modes = {
		char = {
			enabled = false, -- Disable in favor of default f/t
		},
	},
})

vim.keymap.set({ "n", "x", "o" }, "s", function()
	require("flash").jump()
end, { desc = "Flash jump" })

vim.keymap.set({ "n", "x", "o" }, "S", function()
	require("flash").treesitter()
end, { desc = "Flash treesitter" })

-- ts_context_commentstring for better comment detection
add("JoosepAlviste/nvim-ts-context-commentstring")

require("ts_context_commentstring").setup({
	enable_autocmd = false,
})

-- Refactoring.nvim
add({
	source = "ThePrimeagen/refactoring.nvim",
	depends = { "nvim-lua/plenary.nvim" },
})

MiniDeps.later(function()
	require("refactoring").setup({})

	-- Refactoring keymaps
	vim.keymap.set("x", "<leader>re", function()
		require("refactoring").refactor("Extract Function")
	end, { desc = "Extract function" })

	vim.keymap.set("x", "<leader>rf", function()
		require("refactoring").refactor("Extract Function To File")
	end, { desc = "Extract function to file" })

	vim.keymap.set("x", "<leader>rv", function()
		require("refactoring").refactor("Extract Variable")
	end, { desc = "Extract variable" })

	vim.keymap.set("n", "<leader>rI", function()
		require("refactoring").refactor("Inline Function")
	end, { desc = "Inline function" })

	vim.keymap.set({ "n", "x" }, "<leader>ri", function()
		require("refactoring").refactor("Inline Variable")
	end, { desc = "Inline variable" })

	vim.keymap.set("n", "<leader>rb", function()
		require("refactoring").refactor("Extract Block")
	end, { desc = "Extract block" })

	vim.keymap.set("n", "<leader>rB", function()
		require("refactoring").refactor("Extract Block To File")
	end, { desc = "Extract block to file" })

	-- Prompt for refactor
	vim.keymap.set({ "n", "x" }, "<leader>rr", function()
		require("refactoring").select_refactor()
	end, { desc = "Select refactor" })
end)

-- Todo comments (highlight TODO/FIXME/NOTE/HACK/WARN etc.)
add({
	source = "folke/todo-comments.nvim",
	depends = { "nvim-lua/plenary.nvim" },
})
require("todo-comments").setup({})

-- Keymaps
map("n", "]t", function() require("todo-comments").jump_next() end, { desc = "Next TODO comment" })
map("n", "[t", function() require("todo-comments").jump_prev() end, { desc = "Previous TODO comment" })
map("n", "<leader>ft", "<cmd>TodoQuickFix<CR>", { desc = "Find TODOs (quickfix)" })
map("n", "<leader>xt", "<cmd>TodoTrouble<CR>", { desc = "TODOs (Trouble)" })
map("n", "<leader>xT", "<cmd>TodoTrouble keywords=TODO,FIX,FIXME<CR>", { desc = "TODO/FIX/FIXME (Trouble)" })
