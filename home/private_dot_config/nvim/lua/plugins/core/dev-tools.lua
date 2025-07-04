return {
  -- ============================================================================
  -- DEVELOPMENT TOOLS
  -- ============================================================================

  -- AI Code Completion
  {
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    event = 'InsertEnter',
    opts = {
      suggestion = { enabled = false },
      panel = { enabled = false },
      filetypes = {
        markdown = true,
        help = true,
      },
      lsp_binary = 'copilot-language-server',
    },
  },

  -- Debug Adapter Protocol
  {
    'mfussenegger/nvim-dap',
    cmd = { 'DapToggleBreakpoint', 'DapContinue' },
    dependencies = {
      -- Mason integration for debug adapters
      {
        'williamboman/mason.nvim',
        opts = { ensure_installed = { 'codelldb' } },
      },
      -- DAP UI
      {
        'rcarriga/nvim-dap-ui',
        dependencies = { 'nvim-neotest/nvim-nio' },
        opts = {},
      },
      -- Virtual text for variables during debugging
      {
        'theHamsta/nvim-dap-virtual-text',
        opts = {},
      },
    },
    keys = {
      { '<leader>db', '<cmd>DapToggleBreakpoint<CR>', desc = 'Toggle Breakpoint' },
      { '<leader>dc', '<cmd>DapContinue<CR>', desc = 'Continue' },
      { '<leader>di', '<cmd>DapStepInto<CR>', desc = 'Step Into' },
      { '<leader>do', '<cmd>DapStepOver<CR>', desc = 'Step Over' },
      { '<leader>dO', '<cmd>DapStepOut<CR>', desc = 'Step Out' },
      { '<leader>dt', '<cmd>DapTerminate<CR>', desc = 'Terminate' },
    },
    opts = function()
      local dap = require 'dap'

      -- Configure C/C++ debugger (codelldb)
      if not dap.adapters['codelldb'] then
        dap.adapters['codelldb'] = {
          type = 'server',
          host = 'localhost',
          port = '${port}',
          executable = {
            command = 'codelldb',
            args = {
              '--port',
              '${port}',
            },
          },
        }
      end

      -- Add configurations for C and C++
      for _, lang in ipairs { 'c', 'cpp' } do
        dap.configurations[lang] = {
          {
            type = 'codelldb',
            request = 'launch',
            name = 'Launch file',
            program = function()
              return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
            end,
            cwd = '${workspaceFolder}',
            stopOnEntry = false,
          },
          {
            type = 'codelldb',
            request = 'attach',
            name = 'Attach to process',
            pid = require('dap.utils').pick_process,
            cwd = '${workspaceFolder}',
            stopOnEntry = false,
          },
        }
      end
    end,
    config = function(_, opts)
      -- Apply DAP configurations
      opts()

      -- Setup DAP UI when DAP is used
      local dapui = require 'dapui'
      dapui.setup()

      -- Automatically open and close DAP UI
      local dap = require 'dap'
      dap.listeners.after.event_initialized['dapui_config'] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated['dapui_config'] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited['dapui_config'] = function()
        dapui.close()
      end
    end,
  },

  -- Code refactoring tools
  {
    'ThePrimeagen/refactoring.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
    keys = function()
      -- Refactoring picker function
      local pick = function()
        local refactoring = require 'refactoring'
        local fzf_lua = require 'fzf-lua'
        local results = refactoring.get_refactors()

        local opts = {
          fzf_opts = {},
          fzf_colors = true,
          actions = {
            ['default'] = function(selected)
              refactoring.refactor(selected[1])
            end,
          },
        }
        fzf_lua.fzf_exec(results, opts)
      end

      return {
        { '<leader>r', '', desc = '+refactor', mode = { 'n', 'v' } },
        { '<leader>rs', pick, mode = 'v', desc = 'Refactor' },
        {
          '<leader>ri',
          function()
            require('refactoring').refactor 'Inline Variable'
          end,
          mode = { 'n', 'v' },
          desc = 'Inline Variable',
        },
        {
          '<leader>rb',
          function()
            require('refactoring').refactor 'Extract Block'
          end,
          desc = 'Extract Block',
        },
        {
          '<leader>rf',
          function()
            require('refactoring').refactor 'Extract Block To File'
          end,
          desc = 'Extract Block To File',
        },
        {
          '<leader>rP',
          function()
            require('refactoring').debug.printf { below = false }
          end,
          desc = 'Debug Print',
        },
        {
          '<leader>rp',
          function()
            require('refactoring').debug.print_var { normal = true }
          end,
          desc = 'Debug Print Variable',
        },
        {
          '<leader>rc',
          function()
            require('refactoring').debug.cleanup {}
          end,
          desc = 'Debug Cleanup',
        },
        {
          '<leader>rf',
          function()
            require('refactoring').refactor 'Extract Function'
          end,
          mode = 'v',
          desc = 'Extract Function',
        },
        {
          '<leader>rF',
          function()
            require('refactoring').refactor 'Extract Function To File'
          end,
          mode = 'v',
          desc = 'Extract Function To File',
        },
        {
          '<leader>rx',
          function()
            require('refactoring').refactor 'Extract Variable'
          end,
          mode = 'v',
          desc = 'Extract Variable',
        },
        {
          '<leader>rp',
          function()
            require('refactoring').debug.print_var()
          end,
          mode = 'v',
          desc = 'Debug Print Variable',
        },
      }
    end,
    opts = {
      prompt_func_return_type = {
        go = false,
        java = false,
        cpp = false,
        c = false,
        h = false,
        hpp = false,
        cxx = false,
      },
      prompt_func_param_type = {
        go = false,
        java = false,
        cpp = false,
        c = false,
        h = false,
        hpp = false,
        cxx = false,
      },
      printf_statements = {},
      print_var_statements = {},
      show_success_message = true, -- shows a message with information about the refactor on success
    },
  },

  -- Markdown preview and rendering
  {
    'OXY2DEV/markview.nvim',
    ft = { 'markdown', 'quarto', 'rmd', 'codecompanion' },
    cmd = { 'MarkviewOpen', 'MarkviewToggle' },
    dependencies = {
      'nvim-tree/nvim-web-devicons',
      'nvim-treesitter/nvim-treesitter',
    },
    keys = {
      { '<leader>mp', '<cmd>MarkviewToggle<CR>', desc = 'Toggle Markdown Preview' },
    },
    opts = {
      ft = { 'markdown', 'quarto', 'rmd', 'codecompanion' },
      preview = {
        filetypes = { 'markdown', 'quarto', 'rmd', 'codecompanion' },
        buf_ignore = {},
      },
    },
    config = function(_, opts)
      require('markview').setup(opts)

      -- Ensure treesitter has LaTeX grammar for math rendering
      local ts_config = require 'nvim-treesitter.configs'
      local current_config = ts_config.get_module 'ensure_installed' or {}
      if type(current_config) == 'table' then
        if not vim.tbl_contains(current_config, 'latex') then
          table.insert(current_config, 'latex')
          ts_config.setup { ensure_installed = current_config }
        end
      end
    end,
  },

  -- CMake integration
  {
    'Civitasv/cmake-tools.nvim',
    lazy = true,
    init = function()
      local loaded = false
      local function check()
        local cwd = vim.uv.cwd()
        if vim.fn.filereadable(cwd .. '/CMakeLists.txt') == 1 then
          require('lazy').load { plugins = { 'cmake-tools.nvim' } }
          loaded = true
        end
      end
      check()
      vim.api.nvim_create_autocmd('DirChanged', {
        callback = function()
          if not loaded then
            check()
          end
        end,
      })
    end,
    opts = {},
  },
}
