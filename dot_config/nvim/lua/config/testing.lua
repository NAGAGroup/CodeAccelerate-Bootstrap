-- =============================================================================
-- testing.lua — neotest + neotest-gtest + keymaps
-- =============================================================================

local neotest = require("neotest")

neotest.setup({
	adapters = {
		require("neotest-gtest")({}),
	},
})

-- Keymaps (<leader>t prefix)
vim.keymap.set("n", "<leader>tt", function()
	neotest.run.run(vim.fn.expand("%"))
end, { desc = "Test: run file" })
vim.keymap.set("n", "<leader>tn", function()
	neotest.run.run()
end, { desc = "Test: run nearest" })
vim.keymap.set("n", "<leader>td", function()
	neotest.run.run({ strategy = "dap" })
end, { desc = "Test: debug nearest" })
vim.keymap.set("n", "<leader>ts", function()
	neotest.run.stop()
end, { desc = "Test: stop" })
vim.keymap.set("n", "<leader>ta", function()
	neotest.run.attach()
end, { desc = "Test: attach" })
vim.keymap.set("n", "<leader>to", function()
	neotest.output.open({ enter = true })
end, { desc = "Test: output" })
vim.keymap.set("n", "<leader>tO", function()
	neotest.output_panel.toggle()
end, { desc = "Test: output panel" })
vim.keymap.set("n", "<leader>tw", function()
	neotest.watch.toggle(vim.fn.expand("%"))
end, { desc = "Test: watch file" })
vim.keymap.set("n", "<leader>tr", function()
	neotest.run.run_last()
end, { desc = "Test: run last" })
vim.keymap.set("n", "<leader>tx", function()
	neotest.summary.toggle()
end, { desc = "Test: summary" })
