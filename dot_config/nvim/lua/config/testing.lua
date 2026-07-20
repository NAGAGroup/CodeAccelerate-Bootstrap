-- =============================================================================
-- testing.lua — neotest + neotest-gtest + keymaps
-- =============================================================================
-- neotest-gtest parses cpp treesitter queries at require() time, so setup
-- fails on a cold first launch while the cpp parser is still installing
-- (treesitter installs are async). Setup is therefore lazy + retried: eager
-- attempt at startup, re-attempted from keymaps/FileType until it succeeds.
-- =============================================================================

local configured = false

local function ensure_setup()
	if not configured then
		configured = pcall(function()
			require("neotest").setup({
				adapters = {
					require("neotest-gtest")({}),
				},
			})
		end)
	end
	return configured
end

-- Eager attempt (succeeds on every launch except the very first cold start)
ensure_setup()

-- Retry when a testable filetype is opened (parser likely installed by then)
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("neotest_lazy_setup", { clear = true }),
	pattern = { "c", "cpp", "python" },
	callback = function()
		vim.schedule(ensure_setup)
	end,
	desc = "Retry neotest setup once treesitter parsers are available",
})

local function neotest()
	ensure_setup()
	return require("neotest")
end

-- Keymaps (<leader>t prefix)
vim.keymap.set("n", "<leader>tt", function()
	neotest().run.run(vim.fn.expand("%"))
end, { desc = "Test: run file" })
vim.keymap.set("n", "<leader>tn", function()
	neotest().run.run()
end, { desc = "Test: run nearest" })
vim.keymap.set("n", "<leader>td", function()
	neotest().run.run({ strategy = "dap" })
end, { desc = "Test: debug nearest" })
vim.keymap.set("n", "<leader>ts", function()
	neotest().run.stop()
end, { desc = "Test: stop" })
vim.keymap.set("n", "<leader>ta", function()
	neotest().run.attach()
end, { desc = "Test: attach" })
vim.keymap.set("n", "<leader>to", function()
	neotest().output.open({ enter = true })
end, { desc = "Test: output" })
vim.keymap.set("n", "<leader>tO", function()
	neotest().output_panel.toggle()
end, { desc = "Test: output panel" })
vim.keymap.set("n", "<leader>tw", function()
	neotest().watch.toggle(vim.fn.expand("%"))
end, { desc = "Test: watch file" })
vim.keymap.set("n", "<leader>tr", function()
	neotest().run.run_last()
end, { desc = "Test: run last" })
vim.keymap.set("n", "<leader>tx", function()
	neotest().summary.toggle()
end, { desc = "Test: summary" })
