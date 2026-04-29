-- =============================================================================
-- cmake.lua — CMake integration via cmake-tools.nvim
-- =============================================================================

-- Setup
require("cmake-tools").setup({})

-- Keymaps
local cmake = require("cmake-tools")
local map = vim.keymap.set

map("n", "<leader>cmg", "<cmd>CMakeGenerate<CR>", { desc = "CMake: generate" })
map("n", "<leader>cmb", "<cmd>CMakeBuild<CR>", { desc = "CMake: build" })
map("n", "<leader>cmr", cmake.run, { desc = "CMake: run" })
map("n", "<leader>cmt", cmake.run_test, { desc = "CMake: run test" })
map("n", "<leader>cmT", cmake.select_launch_target, { desc = "CMake: select target" })
map("n", "<leader>cmd", cmake.debug, { desc = "CMake: debug" })
map("n", "<leader>cmq", cmake.close_executor, { desc = "CMake: close" })
map("n", "<leader>cmc", cmake.clean, { desc = "CMake: clean" })
map("n", "<leader>cmP", cmake.select_configure_preset, { desc = "CMake: configure preset" })
map("n", "<leader>cmp", cmake.select_build_preset, { desc = "CMake: build preset" })
map("n", "<leader>cmk", cmake.select_kit, { desc = "CMake: select kit" })
map("n", "<leader>cms", cmake.select_build_type, { desc = "CMake: build type" })
