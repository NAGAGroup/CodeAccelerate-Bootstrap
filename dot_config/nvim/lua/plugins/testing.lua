-- Testing framework: neotest
--
-- This module provides a unified interface for running tests across different
-- languages and frameworks.

local add = MiniDeps.add

-- Core neotest and dependencies
add({
	source = "nvim-neotest/neotest",
	depends = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
		"antoinemadec/FixCursorHold.nvim",
		"nvim-neotest/nvim-nio",
	},
})

-- Adapters
add("orjangj/neotest-ctest")

local neotest = require("neotest")

-- Extensible adapter table
local adapters = {
	require("neotest-ctest").setup({}),
}

neotest.setup({
	adapters = adapters,
	status = { virtual_text = true },
	output = { open_on_run = true },
})

-- Testing keymaps
vim.keymap.set("n", "<leader>tr", function()
	neotest.run.run()
end, { desc = "Test: Run nearest" })

vim.keymap.set("n", "<leader>tf", function()
	neotest.run.run(vim.fn.expand("% "))
end, { desc = "Test: Run file" })

vim.keymap.set("n", "<leader>ts", function()
	neotest.summary.toggle()
end, { desc = "Test: Toggle summary" })

vim.keymap.set("n", "<leader>to", function()
	neotest.output.open({ enter = true })
end, { desc = "Test: Show output" })