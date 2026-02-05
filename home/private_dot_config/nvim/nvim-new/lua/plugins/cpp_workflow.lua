-- C/C++ workflow: CMake + DAP

local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

-- CMake tools
later(function()
  add 'Civitasv/cmake-tools.nvim'

  require('cmake-tools').setup {
    cmake_command = 'cmake',
    cmake_build_directory = 'build',
    cmake_generate_options = { '-DCMAKE_EXPORT_COMPILE_COMMANDS=1' },
    cmake_build_options = {},
    cmake_console_size = 10,
    cmake_show_console = 'always',
    cmake_dap_configuration = {
      name = 'Launch file',
      type = 'codelldb',
      request = 'launch',
      stopOnEntry = false,
      runInTerminal = false,
    },
  }

  -- CMake keymaps
  vim.keymap.set('n', '<leader>cg', '<cmd>CMakeGenerate<CR>', { desc = 'CMake: Generate' })
  vim.keymap.set('n', '<leader>cb', '<cmd>CMakeBuild<CR>', { desc = 'CMake: Build' })
  vim.keymap.set('n', '<leader>cr', '<cmd>CMakeRun<CR>', { desc = 'CMake: Run' })
  vim.keymap.set('n', '<leader>ct', '<cmd>CMakeRunTest<CR>', { desc = 'CMake: Run test' })
  vim.keymap.set('n', '<leader>cs', '<cmd>CMakeSelectBuildType<CR>', { desc = 'CMake: Select build type' })
  vim.keymap.set('n', '<leader>cT', '<cmd>CMakeSelectBuildTarget<CR>', { desc = 'CMake: Select build target' })
  vim.keymap.set('n', '<leader>cl', '<cmd>CMakeSelectLaunchTarget<CR>', { desc = 'CMake: Select launch target' })
  vim.keymap.set('n', '<leader>cd', '<cmd>CMakeDebug<CR>', { desc = 'CMake: Debug' })
  vim.keymap.set('n', '<leader>cc', '<cmd>CMakeClose<CR>', { desc = 'CMake: Close console' })
  vim.keymap.set('n', '<leader>ci', '<cmd>CMakeInstall<CR>', { desc = 'CMake: Install' })
  vim.keymap.set('n', '<leader>cC', '<cmd>CMakeClean<CR>', { desc = 'CMake: Clean' })
end)

-- DAP (Debug Adapter Protocol)
later(function()
  add 'mfussenegger/nvim-dap'
  add 'rcarriga/nvim-dap-ui'
  add 'nvim-neotest/nvim-nio' -- Required by nvim-dap-ui

  local dap = require 'dap'
  local dapui = require 'dapui'

  -- Setup dap-ui
  dapui.setup {
    layouts = {
      {
        elements = {
          { id = 'scopes', size = 0.25 },
          { id = 'breakpoints', size = 0.25 },
          { id = 'stacks', size = 0.25 },
          { id = 'watches', size = 0.25 },
        },
        size = 40,
        position = 'left',
      },
      {
        elements = {
          { id = 'repl', size = 0.5 },
          { id = 'console', size = 0.5 },
        },
        size = 10,
        position = 'bottom',
      },
    },
    floating = {
      border = 'rounded',
    },
  }

  -- Auto-open/close dap-ui
  dap.listeners.after.event_initialized['dapui_config'] = function()
    dapui.open()
  end
  dap.listeners.before.event_terminated['dapui_config'] = function()
    dapui.close()
  end
  dap.listeners.before.event_exited['dapui_config'] = function()
    dapui.close()
  end

  -- codelldb adapter configuration
  dap.adapters.codelldb = {
    type = 'server',
    port = '${port}',
    executable = {
      command = vim.fn.stdpath 'data' .. '/mason/bin/codelldb',
      args = { '--port', '${port}' },
    },
  }

  -- C/C++ configurations
  dap.configurations.cpp = {
    {
      name = 'Launch file',
      type = 'codelldb',
      request = 'launch',
      program = function()
        return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
      end,
      cwd = '${workspaceFolder}',
      stopOnEntry = false,
    },
    {
      name = 'Attach to process',
      type = 'codelldb',
      request = 'attach',
      pid = function()
        return tonumber(vim.fn.input 'Process ID: ')
      end,
      cwd = '${workspaceFolder}',
    },
  }
  dap.configurations.c = dap.configurations.cpp

  -- DAP keymaps
  vim.keymap.set('n', '<leader>db', function()
    dap.toggle_breakpoint()
  end, { desc = 'Debug: Toggle breakpoint' })

  vim.keymap.set('n', '<leader>dB', function()
    dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
  end, { desc = 'Debug: Set conditional breakpoint' })

  vim.keymap.set('n', '<leader>dc', function()
    dap.continue()
  end, { desc = 'Debug: Continue' })

  vim.keymap.set('n', '<leader>dn', function()
    dap.step_over()
  end, { desc = 'Debug: Step over' })

  vim.keymap.set('n', '<leader>di', function()
    dap.step_into()
  end, { desc = 'Debug: Step into' })

  vim.keymap.set('n', '<leader>do', function()
    dap.step_out()
  end, { desc = 'Debug: Step out' })

  vim.keymap.set('n', '<leader>dr', function()
    dap.repl.toggle()
  end, { desc = 'Debug: Toggle REPL' })

  vim.keymap.set('n', '<leader>dl', function()
    dap.run_last()
  end, { desc = 'Debug: Run last' })

  vim.keymap.set('n', '<leader>du', function()
    dapui.toggle()
  end, { desc = 'Debug: Toggle UI' })

  vim.keymap.set({ 'n', 'v' }, '<leader>de', function()
    dapui.eval()
  end, { desc = 'Debug: Eval' })

  vim.keymap.set('n', '<leader>dt', function()
    dap.terminate()
  end, { desc = 'Debug: Terminate' })
end)
