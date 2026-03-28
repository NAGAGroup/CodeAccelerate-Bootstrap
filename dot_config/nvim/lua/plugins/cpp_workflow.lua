

-- C/C++ workflow: CMake + DAP

local add = MiniDeps.add

-- =====================================================================
-- DAP (Debug Adapter Protocol) - load FIRST
-- =====================================================================
add("mfussenegger/nvim-dap")
add("rcarriga/nvim-dap-ui")
add("nvim-neotest/nvim-nio") -- Required by nvim-dap-ui

local dap = require("dap")
local dapui = require("dapui")

-- Setup dap-ui
dapui.setup({
	icons = {
		expanded = "", -- U+EAB4 nf-cod-chevron_down
		collapsed = "", -- U+EAB6 nf-cod-chevron_right
		current_frame = "", -- U+EB89 nf-cod-debug_stackframe_active
	},
	controls = {
		enabled = true,
		element = "repl",
		icons = {
			pause = "", -- U+EAD1 nf-cod-debug_pause
			play = "", -- U+EACF nf-cod-debug_continue
			step_into = "", -- U+EAD4 nf-cod-debug_step_into
			step_over = "", -- U+EAD6 nf-cod-debug_step_over
			step_out = "", -- U+EAD5 nf-cod-debug_step_out
			step_back = "", -- U+EB8F nf-cod-debug_step_back
			run_last = "", -- U+EBC0 nf-cod-debug_rerun
			terminate = "", -- U+EAD7 nf-cod-debug_stop
			disconnect = "", -- U+EAD0 nf-cod-debug_disconnect
		},
	},
	layouts = {
		{
			elements = {
				{ id = "scopes", size = 0.25 },
				{ id = "breakpoints", size = 0.25 },
				{ id = "stacks", size = 0.25 },
				{ id = "watches", size = 0.25 },
			},
			size = 40,
			position = "left",
		},
		{
			elements = {
				{ id = "repl", size = 0.5 },
				{ id = "console", size = 0.5 },
			},
			size = 10,
			position = "bottom",
		},
	},
	floating = {
		border = "rounded",
	},
})

-- DAP sign highlight groups
vim.api.nvim_set_hl(0, "DapBreakpoint", { fg = "#e06c75" })
vim.api.nvim_set_hl(0, "DapBreakpointCondition", { fg = "#e5c07b" })
vim.api.nvim_set_hl(0, "DapBreakpointRejected", { fg = "#5c6370" })
vim.api.nvim_set_hl(0, "DapLogPoint", { fg = "#61afef" })
vim.api.nvim_set_hl(0, "DapStopped", { fg = "#98c379" })

-- DAP gutter signs (Nerd Fonts v3 Codicons - no patched font required)
vim.fn.sign_define("DapBreakpoint", {
	text = "", -- U+F111 nf-fa-circle (Solid and larger than the function variant)
	texthl = "DapBreakpoint",
	linehl = "",
	numhl = "",
})
vim.fn.sign_define("DapBreakpointCondition", {
	text = "", -- U+F059 nf-fa-question_circle (Clearer and heavier)
	texthl = "DapBreakpointCondition",
	linehl = "",
	numhl = "",
})
vim.fn.sign_define("DapBreakpointRejected", {
	text = "", -- U+F05C nf-fa-times_circle (Bolder rejection indicator)
	texthl = "DapBreakpointRejected",
	linehl = "",
	numhl = "",
})
vim.fn.sign_define("DapLogPoint", {
	text = "", -- U+F05A nf-fa-info_circle (Standard large info icon for logs)
	texthl = "DapLogPoint",
	linehl = "",
	numhl = "",
})
vim.fn.sign_define("DapStopped", {
	text = "", -- U+EB89 nf-cod-debug_stackframe_active
	texthl = "DapStopped",
	linehl = "debugPC",
	numhl = "",
})

-- Auto-open/close dap-ui
dap.listeners.after.event_initialized["dapui_config"] = function()
	dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
	dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
	dapui.close()
end

-- Auto-close assembly/disassembly source reference buffers opened by the debugger
local function close_dap_src_bufs()
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_valid(buf) then
			local name = vim.api.nvim_buf_get_name(buf)
			if name:match('^dap%-src://') then
				pcall(vim.api.nvim_buf_delete, buf, { force = true })
			end
		end
	end
end
dap.listeners.before.event_terminated["dap_src_close"] = function()
	close_dap_src_bufs()
end
dap.listeners.before.event_exited["dap_src_close"] = function()
	close_dap_src_bufs()
end

-- codelldb adapter configuration
dap.adapters.codelldb = {
	type = "server",
	port = "${port}",
	executable = {
		command = vim.fn.stdpath("data") .. "/mason/bin/codelldb",
		args = { "--port", "${port}" },
	},
}

-- C/C++ configurations
dap.configurations.cpp = {
	{
		name = "Launch file",
		type = "codelldb",
		request = "launch",
		program = function()
			return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
		end,
		cwd = "${workspaceFolder}",
		stopOnEntry = false,
	},
	{
		name = "Attach to process",
		type = "codelldb",
		request = "attach",
		pid = function()
			return tonumber(vim.fn.input("Process ID: "))
		end,
		cwd = "${workspaceFolder}",
	},
}
dap.configurations.c = dap.configurations.cpp

-- Python DAP (debugpy)
dap.adapters.python = {
	type = "executable",
	command = vim.fn.stdpath("data") .. "/mason/bin/debugpy-adapter",
}

dap.configurations.python = {
	{
		type = "python",
		request = "launch",
		name = "Launch file",
		program = "${file}",
		pythonPath = function()
			-- Use virtual env if available
			local venv = vim.fn.getcwd() .. "/.venv/bin/python"
			if vim.fn.executable(venv) == 1 then
				return venv
			end
			return vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
		end,
	},
	{
		type = "python",
		request = "launch",
		name = "Launch file with args",
		program = "${file}",
		args = function()
			local args = vim.fn.input("Program arguments: ")
			return vim.split(args, " ")
		end,
		pythonPath = function()
			local venv = vim.fn.getcwd() .. "/.venv/bin/python"
			if vim.fn.executable(venv) == 1 then
				return venv
			end
			return vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
		end,
	},
}

-- DAP keymaps
vim.keymap.set("n", "<leader>db", function()
	dap.toggle_breakpoint()
end, { desc = "Debug: Toggle breakpoint" })

vim.keymap.set("n", "<leader>dB", function()
	dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "Debug: Set conditional breakpoint" })

vim.keymap.set("n", "<leader>dc", function()
	dap.continue()
end, { desc = "Debug: Continue" })

vim.keymap.set("n", "<leader>dn", function()
	dap.step_over()
end, { desc = "Debug: Step over" })

vim.keymap.set("n", "<leader>di", function()
	dap.step_into()
end, { desc = "Debug: Step into" })

vim.keymap.set("n", "<leader>do", function()
	dap.step_out()
end, { desc = "Debug: Step out" })

vim.keymap.set("n", "<leader>dr", function()
	dap.repl.toggle()
end, { desc = "Debug: Toggle REPL" })

vim.keymap.set("n", "<leader>dl", function()
	dap.run_last()
end, { desc = "Debug: Run last" })

vim.keymap.set("n", "<leader>du", function()
	dapui.toggle()
end, { desc = "Debug: Toggle UI" })

vim.keymap.set({ "n", "v" }, "<leader>de", function()
	dapui.eval()
end, { desc = "Debug: Eval" })

vim.keymap.set("n", "<leader>dt", function()
	dap.terminate()
end, { desc = "Debug: Terminate" })

-- Helper: wrap a dap config to prompt for args before launch (LazyVim pattern)
local function get_args(config)
  return vim.tbl_extend("force", config, {
    args = function()
      local args_str = vim.fn.input({
        prompt = "Args: ",
        default = table.concat(type(config.args) == "table" and config.args or {}, " "),
      })
      return vim.split(args_str, " +", { trimempty = true })
    end,
  })
end

-- Additional DAP keymaps (LazyVim parity)
local function map(mode, lhs, rhs, opts)
  vim.keymap.set(mode, lhs, rhs, opts)
end

map("n", "<leader>da", function() dap.continue({ before = get_args }) end, { desc = "Debug: Run with Args" })
map("n", "<leader>dA", function() dap.run_last({ before = get_args }) end, { desc = "Debug: Run Last with Args" })
map("n", "<leader>dC", function() dap.run_to_cursor() end, { desc = "Debug: Run to Cursor" })
map("n", "<leader>dd", function() dap.disconnect() end, { desc = "Debug: Disconnect" })
map("n", "<leader>ds", function() dap.continue() end, { desc = "Debug: Select Config & Continue" })
map("n", "<leader>dj", function() dap.down() end, { desc = "Debug: Down (stack)" })
map("n", "<leader>dk", function() dap.up() end, { desc = "Debug: Up (stack)" })
map("n", "<leader>dp", function() dap.pause() end, { desc = "Debug: Pause" })
map("n", "<leader>dw", function() require("dap.ui.widgets").hover() end, { desc = "Debug: Hover Eval" })


