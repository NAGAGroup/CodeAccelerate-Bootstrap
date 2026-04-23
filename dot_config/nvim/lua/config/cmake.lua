-- =============================================================================
-- cmake.lua — CMake integration via cmake-tools.nvim
-- =============================================================================

-- Setup
require('cmake-tools').setup({
  cmake_use_preset = true,
  cmake_executor = {
    name = 'terminal',
    opts = {
      split_direction = 'horizontal',
      split_size = 11,
    },
    default_opts = {
      terminal = {
        name = 'CMake Terminal',
        prefix_name = '[CMake]: ',
        split_direction = 'horizontal',
        split_size = 11,
        single_terminal_per_instance = true,
        single_terminal_per_tab = true,
        keep_terminal_static_location = true,
        auto_resize = true,
        start_insert = false,
        focus = false,
        do_not_add_newline = false,
      },
    },
  },
  cmake_runner = {
    name = 'terminal',
    opts = {
      split_direction = 'horizontal',
      split_size = 11,
    },
    default_opts = {
      terminal = {
        name = 'CMake Runner',
        prefix_name = '[CMakeRun]: ',
        split_direction = 'horizontal',
        split_size = 11,
        single_terminal_per_instance = true,
        single_terminal_per_tab = true,
        keep_terminal_static_location = true,
        auto_resize = true,
        start_insert = false,
        focus = false,
        do_not_add_newline = false,
      },
    },
  },
  cmake_dap_configuration = {
    name = 'cpp',
    type = 'codelldb',
    request = 'launch',
    stopOnEntry = false,
    runInTerminal = true,
    console = 'integratedTerminal',
  },
  cmake_dap_configuration_edit_before_launch = true,
})

-- Keymaps
local cmake = require('cmake-tools')
local map = vim.keymap.set

map('n', '<leader>cmg', cmake.generate,                  { desc = 'CMake: generate' })
map('n', '<leader>cmb', cmake.build,                     { desc = 'CMake: build' })
map('n', '<leader>cmr', cmake.run,                       { desc = 'CMake: run' })
map('n', '<leader>cmt', cmake.run_test,                  { desc = 'CMake: run test' })
map('n', '<leader>cmT', cmake.select_launch_target,      { desc = 'CMake: select target' })
map('n', '<leader>cmd', cmake.debug,                     { desc = 'CMake: debug' })
map('n', '<leader>cmq', cmake.close_executor,            { desc = 'CMake: close' })
map('n', '<leader>cmc', cmake.clean,                     { desc = 'CMake: clean' })
map('n', '<leader>cmP', cmake.select_configure_preset,   { desc = 'CMake: configure preset' })
map('n', '<leader>cmp', cmake.select_build_preset,       { desc = 'CMake: build preset' })
map('n', '<leader>cmk', cmake.select_kit,                { desc = 'CMake: select kit' })
map('n', '<leader>cms', cmake.select_build_type,         { desc = 'CMake: build type' })
