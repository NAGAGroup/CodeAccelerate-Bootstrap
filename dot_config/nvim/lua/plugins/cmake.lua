-- CMake build system integration via cmake-tools.nvim

local add = MiniDeps.add

-- cmake-tools.nvim with plenary.nvim dependency
add({
	source = "Civitasv/cmake-tools.nvim",
	depends = { "nvim-lua/plenary.nvim" },
})

-- Setup cmake-tools
require("cmake-tools").setup({
	-- cmake_build_directory is a fallback; when using CMakePresets, binaryDir from
	-- the selected configure preset takes precedence automatically.
	cmake_build_directory = "build/${variant:buildType}",
	cmake_use_preset = true, -- use --preset flag; aligns with `cmake . --preset <name>` workflow
	cmake_dap_configuration = {
		type = "codelldb",
		request = "launch",
		stopOnEntry = false,
	},
	cmake_executor = {
		name = "terminal",
		default_opts = {
			terminal = {
				split_direction = "horizontal",
				split_size = 11,
			},
		},
	},
	cmake_runner = {
		name = "terminal",
		default_opts = {
			terminal = {
				split_direction = "horizontal",
				split_size = 11,
			},
		},
	},
})

-- CMake keymaps
local map = vim.keymap.set
map("n", "<leader>cmg", "<cmd>CMakeGenerate<CR>", { desc = "CMake: Generate" })
map("n", "<leader>cmb", "<cmd>CMakeBuild<CR>", { desc = "CMake: Build" })
map("n", "<leader>cmr", "<cmd>CMakeRun<CR>", { desc = "CMake: Run" })
map("n", "<leader>cmt", "<cmd>CMakeRunTest<CR>", { desc = "CMake: Run Tests" })
map("n", "<leader>cmT", "<cmd>CMakeSelectBuildTarget<CR>", { desc = "CMake: Select Target" })
map("n", "<leader>cmd", "<cmd>CMakeDebug<CR>", { desc = "CMake: Debug" })
map("n", "<leader>cmq", "<cmd>CMakeClose<CR>", { desc = "CMake: Close" })
map("n", "<leader>cmc", "<cmd>CMakeClean<CR>", { desc = "CMake: Clean" })

-- Preset-first workflow (primary path when using CMakePresets.json)
-- These replace the kit/build-type selectors from the variants workflow.
map("n", "<leader>cmP", "<cmd>CMakeSelectConfigurePreset<CR>", { desc = "CMake: Select Configure Preset" })
map("n", "<leader>cmp", "<cmd>CMakeSelectBuildPreset<CR>", { desc = "CMake: Select Build Preset" })

-- Kept for projects that still use kits/variants instead of presets
map("n", "<leader>cmk", "<cmd>CMakeSelectKit<CR>", { desc = "CMake: Select Kit" })
map("n", "<leader>cms", "<cmd>CMakeSelectBuildType<CR>", { desc = "CMake: Select Build Type" })
