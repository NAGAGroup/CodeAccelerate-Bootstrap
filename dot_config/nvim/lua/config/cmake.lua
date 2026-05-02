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
map("n", "<leader>cmB", "<cmd>CMakeSelectBuildTarget<CR>", { desc = "CMake: select build target" })
map("n", "<leader>cmr", "<cmd>CMakeRun<CR>", { desc = "CMake: run" })
map("n", "<leader>cmt", "<cmd>CMakeRunTest<CR>", { desc = "CMake: run test" })
map("n", "<leader>cmT", "<cmd>CMakeSelectLaunchTarget<CR>", { desc = "CMake: select launch target" })
map("n", "<leader>cmd", "<cmd>CMakeDebug<CR>", { desc = "CMake: debug" })
map("n", "<leader>cmc", "<cmd>CMakeClean<CR>", { desc = "CMake: clean" })
map("n", "<leader>cmP", "<cmd>CMakeSelectConfigurePreset<CR>", { desc = "CMake: configure preset" })
map("n", "<leader>cmp", "<cmd>CMakeSelectBuildPreset<CR>", { desc = "CMake: build preset" })
