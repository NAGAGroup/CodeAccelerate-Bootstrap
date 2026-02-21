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
add("rosstang/neotest-catch2")

local neotest = require("neotest")

-- Extensible adapter table
local adapters = {
	require("neotest-catch2")({
		is_test_file = function(file_path)
			if not file_path:match("%.cpp$") and not file_path:match("%.hpp$") then
				return false
			end
			-- Check for Catch2 includes as a marker for prioritization
			local f = io.open(file_path, "r")
			if f then
				local content = f:read("*a")
				f:close()
				if content:find("catch2/") or content:find("CATCH_CONFIG_MAIN") then
					return true
				end
			end
			return false
		end,
	}),
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

vim.keymap.set("n", "<leader>td", function()
	require("neotest").run.run({ strategy = "dap" })
end, { desc = "Test: Debug nearest" })