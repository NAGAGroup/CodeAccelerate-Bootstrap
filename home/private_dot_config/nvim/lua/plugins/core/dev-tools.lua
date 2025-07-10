---@param config {type?:string, args?:string[]|fun():string[]?}
local function get_args(config)
  local args = type(config.args) == 'function' and (config.args() or {}) or config.args or {} --[[@as string[] | string ]]
  local args_str = type(args) == 'table' and table.concat(args, ' ') or args --[[@as string]]

  config = vim.deepcopy(config)
  ---@cast args string[]
  config.args = function()
    local new_args = vim.fn.expand(vim.fn.input('Run with args: ', args_str)) --[[@as string]]
    if config.type and config.type == 'java' then
      ---@diagnostic disable-next-line: return-type-mismatch
      return new_args
    end
    return require('dap.utils').splitstr(new_args)
  end
  return config
end

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
        'williamboman/mason-nvim-dap.nvim',
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
  },
  {
    'mfussenegger/nvim-dap',
    recommended = true,
    desc = 'Debugging support. Requires language specific adapters to be configured. (see lang extras)',

    dependencies = {
      'rcarriga/nvim-dap-ui',
      -- virtual text for the debugger
      {
        'theHamsta/nvim-dap-virtual-text',
        opts = {},
      },
    },

    -- stylua: ignore
    keys = {
      { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = "Breakpoint Condition" },
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
      { "<leader>dc", function() require("dap").continue() end, desc = "Run/Continue" },
      { "<leader>da", function() require("dap").continue({ before = get_args }) end, desc = "Run with Args" },
      { "<leader>dC", function() require("dap").run_to_cursor() end, desc = "Run to Cursor" },
      { "<leader>dg", function() require("dap").goto_() end, desc = "Go to Line (No Execute)" },
      { "<leader>di", function() require("dap").step_into() end, desc = "Step Into" },
      { "<leader>dj", function() require("dap").down() end, desc = "Down" },
      { "<leader>dk", function() require("dap").up() end, desc = "Up" },
      { "<leader>dl", function() require("dap").run_last() end, desc = "Run Last" },
      { "<leader>do", function() require("dap").step_out() end, desc = "Step Out" },
      { "<leader>dO", function() require("dap").step_over() end, desc = "Step Over" },
      { "<leader>dP", function() require("dap").pause() end, desc = "Pause" },
      { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
      { "<leader>ds", function() require("dap").session() end, desc = "Session" },
      { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate" },
      { "<leader>dw", function() require("dap.ui.widgets").hover() end, desc = "Widgets" },
    },

    config = function()
      -- load mason-nvim-dap here, after all adapters have been setup
      require('mason-nvim-dap').setup(NvimLuaUtils.mason_nvim_dap_opts)

      vim.api.nvim_set_hl(0, 'DapStoppedLine', { default = true, link = 'Visual' })

      -- setup dap config by VsCode launch.json file
      local vscode = require 'dap.ext.vscode'
      local json = require 'plenary.json'
      vscode.json_decode = function(str)
        return vim.json.decode(json.json_strip_comments(str))
      end
    end,
  },

  -- fancy UI for the debugger
  {
    'rcarriga/nvim-dap-ui',
    dependencies = { 'nvim-neotest/nvim-nio' },
    -- stylua: ignore
    keys = {
      { "<leader>du", function() require("dapui").toggle({ }) end, desc = "Dap UI" },
      { "<leader>de", function() require("dapui").eval() end, desc = "Eval", mode = {"n", "v"} },
    },
    opts = {},
    config = function(_, opts)
      local dap = require 'dap'
      local dapui = require 'dapui'
      dapui.setup(opts)
      dap.listeners.after.event_initialized['dapui_config'] = function()
        dapui.open {}
      end
      dap.listeners.before.event_terminated['dapui_config'] = function()
        dapui.close {}
      end
      dap.listeners.before.event_exited['dapui_config'] = function()
        dapui.close {}
      end
    end,
  },

  -- mason.nvim integration
  {
    'jay-babu/mason-nvim-dap.nvim',
    dependencies = 'mason.nvim',
    cmd = { 'DapInstall', 'DapUninstall' },
    opts = {
      -- Makes a best effort to setup the various debuggers with
      -- reasonable debug configurations
      automatic_installation = true,

      -- You can provide additional configuration to the handlers,
      -- see mason-nvim-dap README for more information
      handlers = {},

      -- You'll need to check that you have the required things installed
      -- online, please don't ask me how to install them :)
      ensure_installed = {
        -- Update this to ensure that you have the debuggers for the langs you want
      },
    },
    -- mason-nvim-dap is loaded when nvim-dap loads
    config = function(_, opts)
      NvimLuaUtils.mason_nvim_dap_opts = opts
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
