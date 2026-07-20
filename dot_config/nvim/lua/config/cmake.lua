-- =============================================================================
-- cmake.lua — cmake-tools.nvim + DAP integration
-- =============================================================================

require("cmake-tools").setup({
	cmake_generate_options = { "-DCMAKE_EXPORT_COMPILE_COMMANDS=1" },
	cmake_compile_commands_options = {
		action = "soft_link",
		target = vim.uv.cwd(), -- string path, not the function itself
	},
	cmake_dap_configuration = {
		name = "cpp",
		type = "codelldb",
		request = "launch",
		stopOnEntry = false,
		runInTerminal = true,
	},
})

-- Keymaps (<leader>cm prefix)
local map = vim.keymap.set
map("n", "<leader>cmg", "<cmd>CMakeGenerate<CR>", { desc = "CMake: generate" })
map("n", "<leader>cmb", "<cmd>CMakeBuild<CR>", { desc = "CMake: build" })
map("n", "<leader>cmB", "<cmd>CMakeSelectBuildTarget<CR>", { desc = "CMake: select build target" })
map("n", "<leader>cmr", "<cmd>CMakeRun<CR>", { desc = "CMake: run" })
map("n", "<leader>cmt", "<cmd>CMakeRunTest<CR>", { desc = "CMake: run test" })
map("n", "<leader>cmT", "<cmd>CMakeSelectLaunchTarget<CR>", { desc = "CMake: select launch target" })
map("n", "<leader>cmd", "<cmd>CMakeDebug<CR>", { desc = "CMake: debug" })
map("n", "<leader>cmc", "<cmd>CMakeClean<CR>", { desc = "CMake: clean" })
map("n", "<leader>cmP", "<cmd>CMakeSelectConfigurePreset<CR>", { desc = "CMake: configure preset" })
map("n", "<leader>cmp", "<cmd>CMakeSelectBuildPreset<CR>", { desc = "CMake: build preset" })
