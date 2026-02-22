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
add("Shatur/neovim-tasks")
add("rosstang/neotest-catch2")

local tasks = require("tasks")

local get_build_dir = function()
	local ok, ProjectConfig = pcall(require, "tasks.project_config")
	if not ok then
		return "build"
	end

	local project_config = ProjectConfig.new()
	local kit = project_config.cmake.build_kit
	local build_type = project_config.cmake.build_type

	-- Fallback to defaults if not set or placeholders
	if not kit or kit == "{build_kit}" then
		kit = "debug"
	end
	if not build_type or build_type == "{build_type}" then
		build_type = "Debug"
	end

	local Path = require("plenary.path")
	return tostring(Path:new(vim.fn.getcwd(), "build", kit, build_type))
end

tasks.setup({
	default_params = {
		cmake = {
			cmake_kits_file = "cmake_kits.json",
			dap_name = "codelldb",
			build_dir = get_build_dir,
		},
	},
})

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

-- neovim-tasks keymaps
vim.keymap.set("n", "<leader>cmg", "<cmd>Task start cmake configure<CR>", { desc = "CMake: Configure" })
vim.keymap.set("n", "<leader>cmb", "<cmd>Task start cmake build<CR>", { desc = "CMake: Build" })
vim.keymap.set("n", "<leader>cmr", "<cmd>Task start cmake run<CR>", { desc = "CMake: Run" })
vim.keymap.set("n", "<leader>cmt", "<cmd>Task start cmake ctest<CR>", { desc = "CMake: Run tests (ctest)" })
vim.keymap.set("n", "<leader>cmk", "<cmd>Task set_module_param cmake build_kit<CR>", { desc = "CMake: Select Kit" })
vim.keymap.set("n", "<leader>cms", "<cmd>Task set_module_param cmake build_type<CR>", { desc = "CMake: Select Build Type" })
vim.keymap.set("n", "<leader>cmT", "<cmd>Task set_module_param cmake target<CR>", { desc = "CMake: Select Target" })
vim.keymap.set("n", "<leader>cmd", "<cmd>Task start cmake debug<CR>", { desc = "CMake: Debug" })
vim.keymap.set("n", "<leader>cmx", "<cmd>Task cancel<CR>", { desc = "CMake: Cancel task" })



