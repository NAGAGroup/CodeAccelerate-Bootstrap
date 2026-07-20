-- =============================================================================
-- dap.lua — nvim-dap + nvim-dap-view + mason-nvim-dap + keymaps
-- =============================================================================
-- nvim-dap-view: single-window winbar-tabbed UI (replaces nvim-dap-ui)
-- Built-in virtual text (replaces nvim-dap-virtual-text)
-- auto_toggle: auto open/close on session start/end
-- No F-keys — all <leader>d* keymaps
-- =============================================================================

local dap = require("dap")

-- codelldb adapter (C/C++/Rust/Zig/Swift) — explicit server-mode override
dap.adapters.codelldb = {
	type = "server",
	port = "${port}",
	executable = {
		command = vim.fn.stdpath("data") .. "/mason/bin/codelldb",
		args = { "--port", "${port}" },
	},
}

-- C/C++ launch configurations — dynamic program (cmake-tools first, manual fallback)
dap.configurations.cpp = {
	{
		name = "Launch file",
		type = "codelldb",
		request = "launch",
		program = function()
			local ok, cmake = pcall(require, "cmake-tools")
			if ok and cmake.get_launch_target_path() then
				return cmake.get_launch_target_path()
			end
			return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
		end,
		cwd = "${workspaceFolder}",
		stopOnEntry = false,
	},
	{
		name = "Attach to process",
		type = "codelldb",
		request = "attach",
		processId = require("dap.utils").pick_process,
		cwd = "${workspaceFolder}",
	},
}
dap.configurations.c = dap.configurations.cpp

-- nvim-dap-view setup
require("dap-view").setup({
	winbar = {
		show = true,
		show_keymap_hints = true,
		controls = { enabled = true },
	},
	windows = {
		size = 0.25,
		position = "below",
		terminal = {
			size = 0.5,
			position = "left",
		},
	},
	auto_toggle = true,
	follow_tab = true,
	virtual_text = {
		enabled = true,
		position = "inline",
	},
	switchbuf = "usetab,uselast",
})

-- Prevent nvim-dap from overriding the view window
dap.defaults.fallback.switchbuf = "usevisible,usetab,newtab"

-- Signs
vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DapBreakpoint" })
vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DapBreakpointCondition" })
vim.fn.sign_define("DapBreakpointRejected", { text = "○", texthl = "DapBreakpointRejected" })
vim.fn.sign_define("DapLogPoint", { text = "◆", texthl = "DapLogPoint" })
vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DapStopped", linehl = "DapStoppedLine", numhl = "DapStoppedLine" })

-- mason-nvim-dap — handlers = {} (empty table) triggers default_setup for ALL adapters
-- default_setup registers dap.adapters[name] + dap.configurations[ft] from built-in mappings
-- Our codelldb override above takes precedence (set before mason-nvim-dap setup)
require("mason-nvim-dap").setup({
	ensure_installed = { "codelldb", "debugpy" },
	automatic_installation = true,
	handlers = {},
})

-- Keymaps — ALL <leader>d* (no F-keys)
vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "DAP: Continue/Start" })
vim.keymap.set("n", "<leader>dn", dap.step_over, { desc = "DAP: Step over" })
vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "DAP: Step into" })
vim.keymap.set("n", "<leader>do", dap.step_out, { desc = "DAP: Step out" })
vim.keymap.set("n", "<leader>dp", dap.pause, { desc = "DAP: Pause" })
vim.keymap.set("n", "<leader>dt", dap.terminate, { desc = "DAP: Terminate" })
vim.keymap.set("n", "<leader>dL", dap.run_last, { desc = "DAP: Run last" })
vim.keymap.set("n", "<leader>dC", dap.run_to_cursor, { desc = "DAP: Run to cursor" })
vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "DAP: Toggle breakpoint" })
vim.keymap.set("n", "<leader>dB", function()
	dap.set_breakpoint(vim.fn.input("Condition: "))
end, { desc = "DAP: Conditional breakpoint" })
vim.keymap.set("n", "<leader>dl", function()
	dap.set_breakpoint(nil, nil, vim.fn.input("Log message: "))
end, { desc = "DAP: Logpoint" })
vim.keymap.set("n", "<leader>du", "<cmd>DapViewToggle<cr>", { desc = "DAP: Toggle UI" })
vim.keymap.set({ "n", "v" }, "<leader>dh", "<cmd>DapViewHover<cr>", { desc = "DAP: Hover eval" })
vim.keymap.set("n", "<leader>da", "<cmd>DapViewWatch<cr>", { desc = "DAP: Add watch" })
vim.keymap.set("n", "<leader>dj", dap.down, { desc = "DAP: Stack down" })
vim.keymap.set("n", "<leader>dk", dap.up, { desc = "DAP: Stack up" })
