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
		name = "Launch file (args)",
		type = "codelldb",
		request = "launch",
		program = function()
			local ok, cmake = pcall(require, "cmake-tools")
			if ok and cmake.get_launch_target_path() then
				return cmake.get_launch_target_path()
			end
			return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
		end,
		args = function()
			return vim.split(vim.fn.input("Args: "), " +", { trimempty = true })
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
		size = 0.35, -- 35% of columns
		position = "right", -- vertical column on the RHS
		terminal = {
			size = 0.3, -- bottom 30% of the column
			position = "below",
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

-- Sign highlight groups — NOBODY defines Dap* sign groups (nvim-dap's own
-- defaults use plain SignColumn, ayu only themes DapUI*), so without these
-- links the signs render in faint SignColumn gray. Re-applied on ColorScheme
-- because :colorscheme (applied at end of init.lua) clears user groups.
local function dap_sign_hl()
	vim.api.nvim_set_hl(0, "DapBreakpoint", { link = "DiagnosticError" })
	vim.api.nvim_set_hl(0, "DapBreakpointCondition", { link = "DiagnosticWarn" })
	vim.api.nvim_set_hl(0, "DapBreakpointRejected", { link = "Comment" })
	vim.api.nvim_set_hl(0, "DapLogPoint", { link = "DiagnosticInfo" })
	vim.api.nvim_set_hl(0, "DapStopped", { link = "DiagnosticOk" })
	vim.api.nvim_set_hl(0, "DapStoppedLine", { link = "Visual" })
end
dap_sign_hl()
vim.api.nvim_create_autocmd("ColorScheme", {
	group = vim.api.nvim_create_augroup("dap_sign_hl", { clear = true }),
	callback = dap_sign_hl,
	desc = "Re-apply DAP sign highlights after colorscheme load",
})

-- Signs
vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DapBreakpoint" })
vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DapBreakpointCondition" })
vim.fn.sign_define("DapBreakpointRejected", { text = "○", texthl = "DapBreakpointRejected" })
vim.fn.sign_define("DapLogPoint", { text = "◆", texthl = "DapLogPoint" })
vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DapStopped", linehl = "DapStoppedLine", numhl = "DapStoppedLine" })

-- mason-nvim-dap — default_setup auto-configures adapters on install (it hooks
-- package:install:success, so adapters installed later by auto-setup.lua get
-- configured too).
-- IMPORTANT: default_setup OVERWRITES dap.adapters[name] and list_extends
-- dap.configurations[ft] — so codelldb gets an explicit no-op handler to keep
-- our server-mode adapter + cmake-tools-aware launch configs above intact.
-- NOTE: ensure_installed and automatic_installation are intentionally OFF —
-- both race auto-setup.lua's per-filetype installs on cold start (mason
-- asserts "Package is already installing"). ALL adapter installation is
-- filetype-driven via auto-setup.lua; mason-nvim-dap's job here is purely
-- configuration: its package:install:success hook runs these handlers when
-- any adapter finishes installing.
require("mason-nvim-dap").setup({
	ensure_installed = {},
	handlers = {
		function(config) -- default handler for everything else
			require("mason-nvim-dap").default_setup(config)
		end,
		codelldb = function() end, -- no-op: keep our custom adapter + configurations
		python = function(config)
			-- venv-aware pythonPath (default config only checks VIRTUAL_ENV/CONDA)
			local function python_path()
				local candidates = {
					vim.fn.getcwd() .. "/.venv/bin/python",
					(os.getenv("VIRTUAL_ENV") or "") .. "/bin/python",
					(os.getenv("CONDA_PREFIX") or "") .. "/bin/python",
				}
				for _, p in ipairs(candidates) do
					if vim.fn.executable(p) == 1 then
						return p
					end
				end
				return vim.fn.exepath("python3") ~= "" and vim.fn.exepath("python3") or "python"
			end
			config.configurations = {
				{
					name = "Python: launch file",
					type = "python",
					request = "launch",
					program = "${file}",
					pythonPath = python_path,
					console = "integratedTerminal",
				},
				{
					name = "Python: launch file (args)",
					type = "python",
					request = "launch",
					program = "${file}",
					args = function()
						return vim.split(vim.fn.input("Args: "), " +", { trimempty = true })
					end,
					pythonPath = python_path,
					console = "integratedTerminal",
				},
				{
					name = "Python: attach to process",
					type = "python",
					request = "attach",
					processId = require("dap.utils").pick_process,
					pythonPath = python_path,
				},
			}
			require("mason-nvim-dap").default_setup(config)
		end,
	},
})

-- =============================================================================
-- Adapters NOT in mason-nvim-dap's mapping — auto-setup.lua installs them, but
-- they must be registered manually (default_setup never sees them):
-- rdbg (ruby), local-lua (lua), ocamlearlybird (ocaml), perl, robotcode (robot)
-- =============================================================================
local mason_pkg = vim.fn.stdpath("data") .. "/mason/packages"

dap.adapters.ruby = function(callback, config)
	callback({
		type = "server",
		host = "127.0.0.1",
		port = "${port}",
		executable = {
			command = "rdbg",
			args = { "--open", "--port", "${port}", "-c", "--", "ruby", config.script or "${file}" },
		},
	})
end
dap.configurations.ruby = {
	{ name = "Ruby: run current file", type = "ruby", request = "attach", script = "${file}", localfs = true },
}

dap.adapters["local-lua"] = {
	type = "executable",
	command = "node",
	args = { mason_pkg .. "/local-lua-debugger-vscode/extension/debugAdapter.js" },
	enrich_config = function(config, on_config)
		if not config.extensionPath then
			local c = vim.deepcopy(config)
			c.extensionPath = mason_pkg .. "/local-lua-debugger-vscode/"
			on_config(c)
		else
			on_config(config)
		end
	end,
}
dap.configurations.lua = {
	{
		name = "Lua: run current file",
		type = "local-lua",
		request = "launch",
		cwd = "${workspaceFolder}",
		program = { lua = "lua", file = "${file}" },
	},
}

dap.adapters.ocamlearlybird = { type = "executable", command = "ocamlearlybird", args = { "debug" } }
dap.configurations.ocaml = {
	{
		name = "OCaml: debug bytecode",
		type = "ocamlearlybird",
		request = "launch",
		program = function()
			return vim.fn.input("Path to bytecode (*.bc): ", vim.fn.getcwd() .. "/", "file")
		end,
	},
}

dap.adapters.perl = { type = "executable", command = "perl-debug-adapter", args = {} }
dap.configurations.perl = {
	{ name = "Perl: run current file", type = "perl", request = "launch", program = "${file}" },
}

dap.adapters.robotcode = { type = "executable", command = "robotcode", args = { "debug" } }
dap.configurations.robot = {
	{ name = "Robot: run current suite", type = "robotcode", request = "launch", target = "${file}" },
}

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
