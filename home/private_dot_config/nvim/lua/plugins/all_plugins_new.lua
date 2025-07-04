return {
  -- ============================================================================
  -- CORE SYSTEM & DEPENDENCIES
  -- ============================================================================
  -- Lua utility library (required by many plugins)
  'nvim-lua/plenary.nvim',
  -- NvChad UI framework
  {
    'nvchad/ui',
    config = function()
      require 'nvchad'
    end,
  },

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

  -- ============================================================================
  -- FILE MANAGEMENT & SESSIONS
  -- ============================================================================

  -- Mini file manager
  {
    'echasnovski/mini.files',
    keys = {
      {
        '<leader>fm',
        function()
          require('mini.files').open(vim.api.nvim_buf_get_name(0), true)
        end,
        desc = 'Open mini.files (Directory of Current File)',
      },
      {
        '<leader>fM',
        function()
          require('mini.files').open(vim.uv.cwd(), true)
        end,
        desc = 'Open mini.files (cwd)',
      },
    },
    opts = {
      windows = {
        preview = true,
        width_focus = 30,
        width_preview = 30,
      },
      options = {
        -- Whether to use for editing directories
        -- Disabled by default in LazyVim because neo-tree is used for that
        use_as_default_explorer = false,
      },
    },
    config = function(_, opts)
      require('mini.files').setup(opts)

      local show_dotfiles = true
      local filter_show = function(fs_entry)
        return true
      end
      local filter_hide = function(fs_entry)
        return not vim.startswith(fs_entry.name, '.')
      end

      local toggle_dotfiles = function()
        show_dotfiles = not show_dotfiles
        local new_filter = show_dotfiles and filter_show or filter_hide
        require('mini.files').refresh { content = { filter = new_filter } }
      end

      local map_split = function(buf_id, lhs, direction, close_on_file)
        local rhs = function()
          local new_target_window
          local cur_target_window = require('mini.files').get_explorer_state().target_window
          if cur_target_window ~= nil then
            vim.api.nvim_win_call(cur_target_window, function()
              vim.cmd('belowright ' .. direction .. ' split')
              new_target_window = vim.api.nvim_get_current_win()
            end)

            require('mini.files').set_target_window(new_target_window)
            require('mini.files').go_in { close_on_file = close_on_file }
          end
        end

        local desc = 'Open in ' .. direction .. ' split'
        if close_on_file then
          desc = desc .. ' and close'
        end
        vim.keymap.set('n', lhs, rhs, { buffer = buf_id, desc = desc })
      end

      local files_set_cwd = function()
        local cur_entry_path = MiniFiles.get_fs_entry().path
        local cur_directory = vim.fs.dirname(cur_entry_path)
        if cur_directory ~= nil then
          vim.fn.chdir(cur_directory)
        end
      end

      vim.api.nvim_create_autocmd('User', {
        pattern = 'MiniFilesBufferCreate',
        callback = function(args)
          local buf_id = args.data.buf_id

          vim.keymap.set('n', opts.mappings and opts.mappings.toggle_hidden or 'g.', toggle_dotfiles, { buffer = buf_id, desc = 'Toggle hidden files' })

          vim.keymap.set('n', opts.mappings and opts.mappings.change_cwd or 'gc', files_set_cwd, { buffer = args.data.buf_id, desc = 'Set cwd' })

          map_split(buf_id, opts.mappings and opts.mappings.go_in_horizontal or '<C-w>s', 'horizontal', false)
          map_split(buf_id, opts.mappings and opts.mappings.go_in_vertical or '<C-w>v', 'vertical', false)
          map_split(buf_id, opts.mappings and opts.mappings.go_in_horizontal_plus or '<C-w>S', 'horizontal', true)
          map_split(buf_id, opts.mappings and opts.mappings.go_in_vertical_plus or '<C-w>V', 'vertical', true)
        end,
      })

      vim.api.nvim_create_autocmd('User', {
        pattern = 'MiniFilesActionRename',
        callback = function(event)
          Snacks.rename.on_rename_file(event.data.from, event.data.to)
        end,
      })
    end,
  },

  -- Surround text objects
  {
    'echasnovski/mini.surround',
    keys = function(_, keys)
      -- Mini surround configuration
      local mini_surround_opts = {
        mappings = {
          add = 'gsa', -- Add surrounding in Normal and Visual modes
          delete = 'gsd', -- Delete surrounding
          find = 'gsf', -- Find surrounding (to the right)
          find_left = 'gsF', -- Find surrounding (to the left)
          highlight = 'gsh', -- Highlight surrounding
          replace = 'gsr', -- Replace surrounding
          update_n_lines = 'gsn', -- Update `n_lines`
        },
      }

      -- Populate the keys based on the user's options
      local mappings = {
        { mini_surround_opts.mappings.add, desc = 'Add Surrounding', mode = { 'n', 'v' } },
        { mini_surround_opts.mappings.delete, desc = 'Delete Surrounding' },
        { mini_surround_opts.mappings.find, desc = 'Find Right Surrounding' },
        { mini_surround_opts.mappings.find_left, desc = 'Find Left Surrounding' },
        { mini_surround_opts.mappings.highlight, desc = 'Highlight Surrounding' },
        { mini_surround_opts.mappings.replace, desc = 'Replace Surrounding' },
        { mini_surround_opts.mappings.update_n_lines, desc = 'Update `MiniSurround.config.n_lines`' },
      }
      mappings = vim.tbl_filter(function(m)
        return m[1] and #m[1] > 0
      end, mappings)
      return vim.list_extend(mappings, keys)
    end,
    opts = {
      mappings = {
        add = 'gsa', -- Add surrounding in Normal and Visual modes
        delete = 'gsd', -- Delete surrounding
        find = 'gsf', -- Find surrounding (to the right)
        find_left = 'gsF', -- Find surrounding (to the left)
        highlight = 'gsh', -- Highlight surrounding
        replace = 'gsr', -- Replace surrounding
        update_n_lines = 'gsn', -- Update `n_lines`
      },
    },
  },

  -- Session persistence
  {
    'folke/persistence.nvim',
    event = 'BufReadPre',
    opts = {},
    keys = {
      {
        '<leader>qs',
        function()
          require('persistence').load()
        end,
        desc = 'Restore Session',
      },
      {
        '<leader>qS',
        function()
          require('persistence').select()
        end,
        desc = 'Select Session',
      },
      {
        '<leader>ql',
        function()
          require('persistence').load { last = true }
        end,
        desc = 'Restore Last Session',
      },
      {
        '<leader>qd',
        function()
          require('persistence').stop()
        end,
        desc = "Don't Save Current Session",
      },
    },
  },

  -- ============================================================================
  -- SNIPPETS
  -- ============================================================================

  -- Disable builtin snippet support in favor of LuaSnip
  { 'garymjr/nvim-snippets', enabled = false },

  -- LuaSnip snippet engine
  {
    'L3MON4D3/LuaSnip',
    lazy = true,
    dependencies = {
      {
        'rafamadriz/friendly-snippets',
        config = function()
          require('luasnip.loaders.from_vscode').lazy_load()
          require('luasnip.loaders.from_vscode').lazy_load { paths = { vim.fn.stdpath 'config' .. '/snippets' } }
        end,
      },
    },
    opts = {
      history = true,
      delete_check_events = 'TextChanged',
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

  -- ============================================================================
  -- FILE MANAGEMENT & SESSIONS
  -- ============================================================================

  -- Mini file manager
  {
    'echasnovski/mini.files',
    keys = {
      {
        '<leader>fm',
        function()
          require('mini.files').open(vim.api.nvim_buf_get_name(0), true)
        end,
        desc = 'Open mini.files (Directory of Current File)',
      },
      {
        '<leader>fM',
        function()
          require('mini.files').open(vim.uv.cwd(), true)
        end,
        desc = 'Open mini.files (cwd)',
      },
    },
    opts = {
      windows = {
        preview = true,
        width_focus = 30,
        width_preview = 30,
      },
      options = {
        -- Whether to use for editing directories
        -- Disabled by default in LazyVim because neo-tree is used for that
        use_as_default_explorer = false,
      },
    },
    config = function(_, opts)
      require('mini.files').setup(opts)

      local show_dotfiles = true
      local filter_show = function(fs_entry)
        return true
      end
      local filter_hide = function(fs_entry)
        return not vim.startswith(fs_entry.name, '.')
      end

      local toggle_dotfiles = function()
        show_dotfiles = not show_dotfiles
        local new_filter = show_dotfiles and filter_show or filter_hide
        require('mini.files').refresh { content = { filter = new_filter } }
      end

      local map_split = function(buf_id, lhs, direction, close_on_file)
        local rhs = function()
          local new_target_window
          local cur_target_window = require('mini.files').get_explorer_state().target_window
          if cur_target_window ~= nil then
            vim.api.nvim_win_call(cur_target_window, function()
              vim.cmd('belowright ' .. direction .. ' split')
              new_target_window = vim.api.nvim_get_current_win()
            end)

            require('mini.files').set_target_window(new_target_window)
            require('mini.files').go_in { close_on_file = close_on_file }
          end
        end

        local desc = 'Open in ' .. direction .. ' split'
        if close_on_file then
          desc = desc .. ' and close'
        end
        vim.keymap.set('n', lhs, rhs, { buffer = buf_id, desc = desc })
      end

      local files_set_cwd = function()
        local cur_entry_path = MiniFiles.get_fs_entry().path
        local cur_directory = vim.fs.dirname(cur_entry_path)
        if cur_directory ~= nil then
          vim.fn.chdir(cur_directory)
        end
      end

      vim.api.nvim_create_autocmd('User', {
        pattern = 'MiniFilesBufferCreate',
        callback = function(args)
          local buf_id = args.data.buf_id

          vim.keymap.set('n', opts.mappings and opts.mappings.toggle_hidden or 'g.', toggle_dotfiles, { buffer = buf_id, desc = 'Toggle hidden files' })

          vim.keymap.set('n', opts.mappings and opts.mappings.change_cwd or 'gc', files_set_cwd, { buffer = args.data.buf_id, desc = 'Set cwd' })

          map_split(buf_id, opts.mappings and opts.mappings.go_in_horizontal or '<C-w>s', 'horizontal', false)
          map_split(buf_id, opts.mappings and opts.mappings.go_in_vertical or '<C-w>v', 'vertical', false)
          map_split(buf_id, opts.mappings and opts.mappings.go_in_horizontal_plus or '<C-w>S', 'horizontal', true)
          map_split(buf_id, opts.mappings and opts.mappings.go_in_vertical_plus or '<C-w>V', 'vertical', true)
        end,
      })

      vim.api.nvim_create_autocmd('User', {
        pattern = 'MiniFilesActionRename',
        callback = function(event)
          Snacks.rename.on_rename_file(event.data.from, event.data.to)
        end,
      })
    end,
  },

  -- Surround text objects
  {
    'echasnovski/mini.surround',
    keys = function(_, keys)
      -- Mini surround configuration
      local mini_surround_opts = {
        mappings = {
          add = 'gsa', -- Add surrounding in Normal and Visual modes
          delete = 'gsd', -- Delete surrounding
          find = 'gsf', -- Find surrounding (to the right)
          find_left = 'gsF', -- Find surrounding (to the left)
          highlight = 'gsh', -- Highlight surrounding
          replace = 'gsr', -- Replace surrounding
          update_n_lines = 'gsn', -- Update `n_lines`
        },
      }

      -- Populate the keys based on the user's options
      local mappings = {
        { mini_surround_opts.mappings.add, desc = 'Add Surrounding', mode = { 'n', 'v' } },
        { mini_surround_opts.mappings.delete, desc = 'Delete Surrounding' },
        { mini_surround_opts.mappings.find, desc = 'Find Right Surrounding' },
        { mini_surround_opts.mappings.find_left, desc = 'Find Left Surrounding' },
        { mini_surround_opts.mappings.highlight, desc = 'Highlight Surrounding' },
        { mini_surround_opts.mappings.replace, desc = 'Replace Surrounding' },
        { mini_surround_opts.mappings.update_n_lines, desc = 'Update `MiniSurround.config.n_lines`' },
      }
      mappings = vim.tbl_filter(function(m)
        return m[1] and #m[1] > 0
      end, mappings)
      return vim.list_extend(mappings, keys)
    end,
    opts = {
      mappings = {
        add = 'gsa', -- Add surrounding in Normal and Visual modes
        delete = 'gsd', -- Delete surrounding
        find = 'gsf', -- Find surrounding (to the right)
        find_left = 'gsF', -- Find surrounding (to the left)
        highlight = 'gsh', -- Highlight surrounding
        replace = 'gsr', -- Replace surrounding
        update_n_lines = 'gsn', -- Update `n_lines`
      },
    },
  },

  -- Session persistence
  {
    'folke/persistence.nvim',
    event = 'BufReadPre',
    opts = {},
    keys = {
      {
        '<leader>qs',
        function()
          require('persistence').load()
        end,
        desc = 'Restore Session',
      },
      {
        '<leader>qS',
        function()
          require('persistence').select()
        end,
        desc = 'Select Session',
      },
      {
        '<leader>ql',
        function()
          require('persistence').load { last = true }
        end,
        desc = 'Restore Last Session',
      },
      {
        '<leader>qd',
        function()
          require('persistence').stop()
        end,
        desc = "Don't Save Current Session",
      },
    },
  },

  -- ============================================================================
  -- SNIPPETS
  -- ============================================================================

  -- Disable builtin snippet support in favor of LuaSnip
  { 'garymjr/nvim-snippets', enabled = false },

  -- LuaSnip snippet engine
  {
    'L3MON4D3/LuaSnip',
    lazy = true,
    dependencies = {
      {
        'rafamadriz/friendly-snippets',
        config = function()
          require('luasnip.loaders.from_vscode').lazy_load()
          require('luasnip.loaders.from_vscode').lazy_load { paths = { vim.fn.stdpath 'config' .. '/snippets' } }
        end,
      },
    },
    opts = {
      history = true,
      delete_check_events = 'TextChanged',
    },
  },

  -- NvChad utilities
  'nvchad/volt',

  -- Lazy.nvim package manager
  { 'folke/lazy.nvim', version = '*' },

  -- Lua development for Neovim
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    cmd = 'LazyDev',
    opts = {
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
        { path = 'snacks.nvim', words = { 'Snacks' } },
      },
    },
  },

  -- Snacks.nvim - Swiss Army knife utility plugin
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    opts = {},
  },

  -- NeoVim UI library
  { 'MunifTanjim/nui.nvim', lazy = true },

  -- ============================================================================
  -- EDITOR CORE
  -- ============================================================================

  -- Treesitter syntax highlighting and parsing
  {
    'nvim-treesitter/nvim-treesitter',
    version = false, -- last release is way too old and doesn't work on Windows
    build = function()
      if vim.fn.exists ':TSUpdate' == 2 then
        vim.cmd 'TSUpdate'
      end
    end,
    lazy = false, -- load treesitter early when opening a file from the cmdline
    cmd = { 'TSUpdateSync', 'TSUpdate', 'TSInstall' },
    keys = {
      { '<c-space>', desc = 'Increment Selection' },
      { '<bs>', desc = 'Decrement Selection', mode = 'x' },
    },
    opts_extend = { 'ensure_installed' },
    ---@type TSConfig
    ---@diagnostic disable-next-line: missing-fields
    opts = {
      highlight = { enable = true },
      indent = { enable = true },
      ensure_installed = {
        'bash',
        'c',
        'cpp',
        'cmake',
        'css',
        'diff',
        'dockerfile',
        'git_config',
        'gitcommit',
        'git_rebase',
        'gitignore',
        'gitattributes',
        'html',
        'javascript',
        'jsdoc',
        'json',
        'json5',
        'jsonc',
        'lua',
        'luadoc',
        'luap',
        'markdown',
        'markdown_inline',
        'nu',
        'printf',
        'python',
        'query',
        'regex',
        'toml',
        'tsx',
        'typescript',
        'vim',
        'vimdoc',
        'xml',
        'yaml',
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = '<C-space>',
          node_incremental = '<C-space>',
          scope_incremental = false,
          node_decremental = '<bs>',
        },
      },
      textobjects = {
        move = {
          enable = true,
          goto_next_start = {
            [']f'] = '@function.outer',
            [']c'] = '@class.outer',
            [']a'] = '@parameter.inner',
          },
          goto_next_end = { [']F'] = '@function.outer', [']C'] = '@class.outer', [']A'] = '@parameter.inner' },
          goto_previous_start = {
            ['[f'] = '@function.outer',
            ['[c'] = '@class.outer',
            ['[a'] = '@parameter.inner',
          },
          goto_previous_end = {
            ['[F'] = '@function.outer',
            ['[C'] = '@class.outer',
            ['[A'] = '@parameter.inner',
          },
        },
      },
    },
    ---@param opts TSConfig
    config = function(_, opts)
      require('nvim-treesitter.configs').setup(opts)
    end,
  },

  -- Treesitter textobjects extension
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    event = 'VeryLazy',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
      -- When in diff mode, we want to use the default
      -- vim text objects c & C instead of the treesitter ones.
      local move = require 'nvim-treesitter.textobjects.move' ---@type table<string,fun(...)>
      local configs = require 'nvim-treesitter.configs'
      for name, fn in pairs(move) do
        if name:find 'goto' == 1 then
          move[name] = function(q, ...)
            if vim.wo.diff then
              local config = configs.get_module('textobjects.move')[name] ---@type table<string,string>
              for key, query in pairs(config or {}) do
                if q == query and key:find '[%]%[][cC]' then
                  vim.cmd('normal! ' .. key)
                  return
                end
              end
            end
            return fn(q, ...)
          end
        end
      end
    end,
  },

  -- Auto-pair brackets, quotes, etc.
  {
    'echasnovski/mini.pairs',
    event = 'VeryLazy',
    opts = {
      modes = { insert = true, command = true, terminal = false },
      -- skip autopair when next character is one of these
      skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
      -- skip autopair when the cursor is inside these treesitter nodes
      skip_ts = { 'string' },
      -- skip autopair when next character is closing pair
      -- and there are more closing pairs than opening pairs
      skip_unbalanced = true,
      -- better deal with markdown code blocks
      markdown = true,
    },
  },

  -- Smart commenting
  {
    'folke/ts-comments.nvim',
    event = 'VeryLazy',
    opts = {},
  },

  -- Enhanced text objects
  {
    'echasnovski/mini.ai',
    event = 'VeryLazy',
    opts = {},
  },

  -- Fast navigation with labels
  {
    'folke/flash.nvim',
    event = 'VeryLazy',
    ---@type Flash.Config
    opts = {},
    keys = {
      {
        's',
        mode = { 'n', 'x', 'o' },
        function()
          require('flash').jump()
        end,
        desc = 'Flash',
      },
      {
        'S',
        mode = { 'n', 'x', 'o' },
        function()
          require('flash').treesitter()
        end,
        desc = 'Flash Treesitter',
      },
      {
        'r',
        mode = 'o',
        function()
          require('flash').remote()
        end,
        desc = 'Remote Flash',
      },
      {
        'R',
        mode = { 'o', 'x' },
        function()
          require('flash').treesitter_search()
        end,
        desc = 'Treesitter Search',
      },
      {
        '<c-s>',
        mode = { 'c' },
        function()
          require('flash').toggle()
        end,
        desc = 'Toggle Flash Search',
      },
    },
  },

  -- Which-key for keybinding hints
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts_extend = { 'spec' },
    opts = {
      preset = 'helix',
      spec = {
        {
          mode = { 'n', 'v' },
          { '<leader><tab>', group = 'tabs' },
          { '<leader>c', group = 'code' },
          { '<leader>d', group = 'debug' },
          { '<leader>dp', group = 'profiler' },
          { '<leader>f', group = 'file/find' },
          { '<leader>g', group = 'git' },
          { '<leader>gh', group = 'hunks' },
          { '<leader>q', group = 'quit/session' },
          { '<leader>s', group = 'search' },
          { '<leader>u', group = 'ui', icon = { icon = '󰙵 ', color = 'cyan' } },
          { '<leader>x', group = 'diagnostics/quickfix', icon = { icon = '󱖫 ', color = 'green' } },
          { '[', group = 'prev' },
          { ']', group = 'next' },
          { 'g', group = 'goto' },
          { 'gs', group = 'surround' },
          { 'z', group = 'fold' },
          {
            '<leader>b',
            group = 'buffer',
            expand = function()
              return require('which-key.extras').expand.buf()
            end,
          },
          {
            '<leader>w',
            group = 'windows',
            proxy = '<c-w>',
            expand = function()
              return require('which-key.extras').expand.win()
            end,
          },
          -- better descriptions
          { 'gx', desc = 'Open with system app' },
          { '<BS>', desc = 'Decrement Selection', mode = 'x' },
          { '<c-space>', desc = 'Increment Selection', mode = { 'x', 'n' } },
        },
      },
    },
    keys = {
      {
        '<leader>?',
        function()
          require('which-key').show { global = false }
        end,
        desc = 'Buffer Keymaps (which-key)',
      },
      {
        '<c-w><space>',
        function()
          require('which-key').show { keys = '<c-w>', loop = true }
        end,
        desc = 'Window Hydra Mode (which-key)',
      },
    },
  },

  -- Auto-close HTML/XML tags
  {
    'windwp/nvim-ts-autotag',
    event = 'VeryLazy',
    opts = {},
  },

  -- Guess indentation automatically
  {
    'nmac427/guess-indent.nvim',
    event = 'BufReadPre',
    config = function()
      require('guess-indent').setup {}
    end,
  },

  -- ============================================================================
  -- UI & APPEARANCE
  -- ============================================================================

  -- Base46 theme and highlight management
  {
    'nvchad/base46',
    lazy = false,
    config = function()
      require('base46').load_all_highlights()
    end,
  },

  -- Enhanced notifications and command line
  {
    'folke/noice.nvim',
    event = 'VeryLazy',
    opts = {
      lsp = {
        override = {
          ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
          ['vim.lsp.util.stylize_markdown'] = true,
          ['cmp.entry.get_documentation'] = true,
        },
      },
      routes = {
        {
          filter = {
            event = 'msg_show',
            any = {
              { find = '%d+L, %d+B' },
              { find = '; after #%d+' },
              { find = '; before #%d+' },
            },
          },
          view = 'mini',
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
      },
    },
    keys = {
      { '<leader>sn', '', desc = '+noice' },
      {
        '<S-Enter>',
        function()
          require('noice').redirect(vim.fn.getcmdline())
        end,
        mode = 'c',
        desc = 'Redirect Cmdline',
      },
      {
        '<leader>snl',
        function()
          require('noice').cmd 'last'
        end,
        desc = 'Noice Last Message',
      },
      {
        '<leader>snh',
        function()
          require('noice').cmd 'history'
        end,
        desc = 'Noice History',
      },
      {
        '<leader>sna',
        function()
          require('noice').cmd 'all'
        end,
        desc = 'Noice All',
      },
      {
        '<leader>snd',
        function()
          require('noice').cmd 'dismiss'
        end,
        desc = 'Dismiss All',
      },
      {
        '<leader>snt',
        function()
          require('noice').cmd 'pick'
        end,
        desc = 'Noice Picker (Telescope/FzfLua)',
      },
      {
        '<c-f>',
        function()
          if not require('noice.lsp').scroll(4) then
            return '<c-f>'
          end
        end,
        silent = true,
        expr = true,
        desc = 'Scroll Forward',
        mode = { 'i', 'n', 's' },
      },
      {
        '<c-b>',
        function()
          if not require('noice.lsp').scroll(-4) then
            return '<c-b>'
          end
        end,
        silent = true,
        expr = true,
        desc = 'Scroll Backward',
        mode = { 'i', 'n', 's' },
      },
    },
    config = function(_, opts)
      -- HACK: noice shows messages from before it was enabled,
      -- but this is not ideal when Lazy is installing plugins,
      -- so clear the messages in this case.
      if vim.o.filetype == 'lazy' then
        vim.cmd [[messages clear]]
      end
      require('noice').setup(opts)
    end,
  },

  -- Modern buffer line
  {
    'akinsho/bufferline.nvim',
    event = 'VeryLazy',
    keys = {
      { '<leader>bs', '<Cmd>BufferLinePick<CR>', desc = 'Select Buffer' },
      { '<leader>bS', '<Cmd>BufferLinePickClose<CR>', desc = 'Select Buffer to Delete' },
      { '<leader>bp', '<Cmd>BufferLineTogglePin<CR>', desc = 'Toggle Pin' },
      { '<leader>bP', '<Cmd>BufferLineGroupClose ungrouped<CR>', desc = 'Delete Non-Pinned Buffers' },
      { '<leader>br', '<Cmd>BufferLineCloseRight<CR>', desc = 'Delete Buffers to the Right' },
      { '<leader>bl', '<Cmd>BufferLineCloseLeft<CR>', desc = 'Delete Buffers to the Left' },
      { '<S-h>', '<cmd>BufferLineCyclePrev<cr>', desc = 'Prev Buffer' },
      { '<S-l>', '<cmd>BufferLineCycleNext<cr>', desc = 'Next Buffer' },
      { '[b', '<cmd>BufferLineCyclePrev<cr>', desc = 'Prev Buffer' },
      { ']b', '<cmd>BufferLineCycleNext<cr>', desc = 'Next Buffer' },
      { '[B', '<cmd>BufferLineMovePrev<cr>', desc = 'Move buffer prev' },
      { ']B', '<cmd>BufferLineMoveNext<cr>', desc = 'Move buffer next' },
    },
    opts = {
      options = {
        close_command = function(n)
          Snacks.bufdelete(n)
        end,
        right_mouse_command = function(n)
          Snacks.bufdelete(n)
        end,
        diagnostics = 'nvim_lsp',
        always_show_bufferline = true,
        offsets = {
          {
            filetype = 'neo-tree',
            text = 'Neo-tree',
            highlight = 'Directory',
            text_align = 'left',
          },
          {
            filetype = 'snacks_layout_box',
          },
        },
      },
    },
    config = function(_, opts)
      require('bufferline').setup(opts)
      -- Fix bufferline when restoring a session
      vim.api.nvim_create_autocmd({ 'BufAdd', 'BufDelete' }, {
        callback = function()
          vim.schedule(function()
            pcall(nvim_bufferline)
          end)
        end,
      })
    end,
  },

  -- Mini icons (replaces nvim-web-devicons)
  {
    'echasnovski/mini.icons',
    lazy = true,
    opts = {
      file = {
        ['.keep'] = { glyph = '󰊢', hl = 'MiniIconsGrey' },
        ['devcontainer.json'] = { glyph = '', hl = 'MiniIconsAzure' },
      },
      filetype = {
        dotenv = { glyph = '', hl = 'MiniIconsYellow' },
      },
    },
    init = function()
      package.preload['nvim-web-devicons'] = function()
        require('mini.icons').mock_nvim_web_devicons()
        return package.loaded['nvim-web-devicons']
      end
    end,
  },

  -- Snacks extensions for various UI features
  {
    'snacks.nvim',
    opts = {
      indent = { enabled = true },
      input = { enabled = true },
      notifier = { enabled = true },
      scope = { enabled = true },
      scroll = { enabled = true },
      statuscolumn = { enabled = false }, -- we set this in options.lua
      toggle = { map = vim.keymap.set },
      words = { enabled = true },
      bigfile = { enabled = true },
      quickfile = { enabled = true },
      terminal = {},
      dashboard = {
        preset = {
          header = [[
        ██╗      █████╗ ███████╗██╗   ██╗██╗   ██╗██╗███╗   ███╗          Z
        ██║     ██╔══██╗╚══███╔╝╚██╗ ██╔╝██║   ██║██║████╗ ████║      Z    
        ██║     ███████║  ███╔╝  ╚████╔╝ ██║   ██║██║██╔████╔██║   z       
        ██║     ██╔══██║ ███╔╝    ╚██╔╝  ╚██╗ ██╔╝██║██║╚██╔╝██║ z         
        ███████╗██║  ██║███████╗   ██║    ╚████╔╝ ██║██║ ╚═╝ ██║           
        ╚══════╝╚═╝  ╚═╝╚══════╝   ╚═╝     ╚═══╝  ╚═╝╚═╝     ╚═╝           
 ]],
          keys = {
            { icon = ' ', key = 'f', desc = 'Find File', action = ":lua Snacks.dashboard.pick('files')" },
            { icon = ' ', key = 'n', desc = 'New File', action = ':ene | startinsert' },
            { icon = ' ', key = 'g', desc = 'Find Text', action = ":lua Snacks.dashboard.pick('live_grep')" },
            { icon = ' ', key = 'r', desc = 'Recent Files', action = ":lua Snacks.dashboard.pick('oldfiles')" },
            { icon = ' ', key = 'c', desc = 'Config', action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
            { icon = ' ', key = 's', desc = 'Restore Session', section = 'session' },
            { icon = ' ', key = 'x', desc = 'Lazy Extras', action = ':LazyExtras' },
            { icon = '󰒲 ', key = 'l', desc = 'Lazy', action = ':Lazy' },
            { icon = ' ', key = 'q', desc = 'Quit', action = ':qa' },
          },
        },
      },
      explorer = {},
    },
    keys = {
      {
        '<leader>n',
        function()
          if Snacks.config.picker and Snacks.config.picker.enabled then
            Snacks.picker.notifications()
          else
            Snacks.notifier.show_history()
          end
        end,
        desc = 'Notification History',
      },
      {
        '<leader>un',
        function()
          Snacks.notifier.hide()
        end,
        desc = 'Dismiss All Notifications',
      },
      {
        '<leader>.',
        function()
          Snacks.scratch()
        end,
        desc = 'Toggle Scratch Buffer',
      },
      {
        '<leader>S',
        function()
          Snacks.scratch.select()
        end,
        desc = 'Select Scratch Buffer',
      },
      {
        '<leader>dps',
        function()
          Snacks.profiler.scratch()
        end,
        desc = 'Profiler Scratch Buffer',
      },
      {
        '<leader>fE',
        function()
          Snacks.explorer()
        end,
        desc = 'Explorer Snacks (cwd)',
      },
      { '<leader>e', '<leader>fe', desc = 'Explorer Snacks (root dir)', remap = true },
      { '<leader>E', '<leader>fE', desc = 'Explorer Snacks (cwd)', remap = true },
    },
  },

  -- Buffer scoping
  { 'tiagovla/scope.nvim', event = 'VeryLazy', config = true },

  -- Show keystrokes on screen
  {
    'nvzone/showkeys',
    cmd = 'ShowkeysToggle',
    opts = {
      timeout = 3, -- in secs
      maxkeys = 10,
      show_count = true,
      excluded_modes = {}, -- example: {"i"}
      position = 'top-center', -- bottom-left, bottom-right, bottom-center, top-left, top-right, top-center
    },
  },

  -- ============================================================================
  -- LSP & COMPLETION
  -- ============================================================================

  -- Completion engine
  {
    'saghen/blink.cmp',
    dependencies = {
      'rafamadriz/friendly-snippets',
      'onsails/lspkind.nvim',
      'nvim-tree/nvim-web-devicons',
      'fang2hou/blink-copilot', -- Copilot integration
    },
    version = '1.*',
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = { preset = 'enter' },
      appearance = {
        nerd_font_variant = 'mono',
      },
      completion = {
        documentation = { auto_show = false },
      },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer', 'copilot' },
        providers = {
          copilot = {
            name = 'copilot',
            module = 'blink-copilot',
            score_offset = 100,
            async = true,
            opts = {
              max_completions = 3,
              max_attempts = 4,
              kind_name = 'Copilot',
              kind_icon = ' ',
              kind_hl = false,
              debounce = 200,
              auto_refresh = {
                backward = true,
                forward = true,
              },
            },
          },
        },
      },
      snippets = {
        preset = 'luasnip',
      },
      fuzzy = { implementation = 'prefer_rust_with_warning' },
    },
    opts_extend = {
      'sources.default',
      'sources.providers',
    },
  },

  -- Mason package manager for LSP servers, formatters, linters
  {
    'williamboman/mason.nvim',
    cmd = 'Mason',
    keys = { { '<leader>cm', '<cmd>Mason<cr>', desc = 'Mason' } },
    build = function()
      if vim.fn.exists ':MasonUpdate' == 2 then
        vim.cmd 'MasonUpdate'
      end
    end,
    opts_extend = { 'ensure_installed' },
    opts = {
      ensure_installed = {
        -- LSP servers
        'lua-language-server',
        'clangd',
        'neocmake',
        'dockerls',
        'docker-compose-language-service',
        'marksman',
        'jsonls',
        'taplo',
        'yamlls',
        -- Formatters
        'stylua',
        'shfmt',
        'prettier',
        'black',
        'markdownlint-cli2',
        'markdown-toc',
        -- Linters
        'cmakelint',
        'hadolint',
        -- Debug adapters
        'codelldb',
        -- Tools
        'cmakelang',
      },
    },
    ---@param opts MasonSettings | {ensure_installed: string[]}
    config = function(_, opts)
      require('mason').setup(opts)
      local mr = require 'mason-registry'
      mr:on('package:install:success', function()
        vim.defer_fn(function()
          -- trigger FileType event to possibly load this newly installed LSP server
          require('lazy.core.handler.event').trigger {
            event = 'FileType',
            buf = vim.api.nvim_get_current_buf(),
          }
        end, 100)
      end)

      mr.refresh(function()
        for _, tool in ipairs(opts.ensure_installed) do
          local p = mr.get_package(tool)
          if not p:is_installed() then
            p:install()
          end
        end
      end)
    end,
  },

  -- Mason LSP configuration
  { 'williamboman/mason-lspconfig.nvim', config = function() end },

  -- LSP configuration
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      'blink.cmp',
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'b0o/SchemaStore.nvim', -- JSON/YAML schemas
    },
    opts = function()
      return {
        -- Diagnostic configuration
        diagnostics = {
          underline = true,
          update_in_insert = false,
          virtual_text = {
            spacing = 4,
            source = 'if_many',
            prefix = '●',
          },
          severity_sort = true,
          signs = true,
        },
        -- LSP server configurations
        servers = {
          lua_ls = {
            settings = {
              Lua = {
                workspace = {
                  checkThirdParty = false,
                },
                codeLens = {
                  enable = true,
                },
                completion = {
                  callSnippet = 'Replace',
                },
                hint = {
                  enable = true,
                  paramType = true,
                },
              },
            },
          },
          -- C/C++ Language Server
          clangd = {
            keys = {
              { '<leader>ch', '<cmd>ClangdSwitchSourceHeader<cr>', desc = 'Switch Source/Header (C/C++)' },
            },
            root_dir = function(fname)
              return require('lspconfig.util').root_pattern(
                'Makefile',
                'configure.ac',
                'configure.in',
                'config.h.in',
                'meson.build',
                'meson_options.txt',
                'build.ninja'
              )(fname) or require('lspconfig.util').root_pattern('compile_commands.json', 'compile_flags.txt')(fname) or require('lspconfig.util').find_git_ancestor(
                fname
              )
            end,
            capabilities = {
              offsetEncoding = { 'utf-16' },
            },
            cmd = {
              'clangd',
              '--background-index',
              '--clang-tidy',
              '--header-insertion=iwyu',
              '--completion-style=detailed',
              '--function-arg-placeholders',
              '--fallback-style=llvm',
            },
            init_options = {
              usePlaceholders = true,
              completeUnimported = true,
              clangdFileStatus = true,
            },
          },
          -- Other language servers
          neocmake = {},
          dockerls = {},
          docker_compose_language_service = {},
          marksman = {},
          jsonls = {
            -- lazy-load schemastore when needed
            on_new_config = function(new_config)
              new_config.settings.json.schemas = new_config.settings.json.schemas or {}
              vim.list_extend(new_config.settings.json.schemas, require('schemastore').json.schemas())
            end,
            settings = {
              json = {
                format = {
                  enable = true,
                },
                validate = { enable = true },
              },
            },
          },
          taplo = {},
          yamlls = {
            -- Have to add this for yamlls to understand that we support line folding
            capabilities = {
              textDocument = {
                foldingRange = {
                  dynamicRegistration = false,
                  lineFoldingOnly = true,
                },
              },
            },
            -- lazy-load schemastore when needed
            on_new_config = function(new_config)
              new_config.settings.yaml.schemas = vim.tbl_deep_extend('force', new_config.settings.yaml.schemas or {}, require('schemastore').yaml.schemas())
            end,
            settings = {
              redhat = { telemetry = { enabled = false } },
              yaml = {
                keyOrdering = false,
                format = {
                  enable = true,
                },
                validate = true,
                schemaStore = {
                  -- Must disable built-in schemaStore support to use
                  -- schemas from SchemaStore.nvim plugin
                  enable = false,
                  -- Avoid TypeError: Cannot read properties of undefined (reading 'length')
                  url = '',
                },
              },
            },
          },
        },
        servers_no_install = {
          nushell = {},
        },
        setup = {
          clangd = function(_, opts)
            local clangd_opts = {
              inlay_hints = {
                inline = false,
              },
              ast = {
                --These require codicons (https://github.com/microsoft/vscode-codicons)
                role_icons = {
                  type = '',
                  declaration = '',
                  expression = '',
                  specifier = '',
                  statement = '',
                  ['template argument'] = '',
                },
                kind_icons = {
                  Compound = '',
                  Recovery = '',
                  TranslationUnit = '',
                  PackExpansion = '',
                  TemplateTypeParm = '',
                  TemplateTemplateParm = '',
                  TemplateParamObject = '',
                },
              },
            }
            require('clangd_extensions').setup(vim.tbl_deep_extend('force', clangd_opts or {}, { server = opts }))
            return false
          end,
        },
      }
    end,
    config = function(_, opts)
      -- Setup Mason
      require('mason').setup()
      require('mason-lspconfig').setup {
        ensure_installed = vim.tbl_keys(opts.servers), -- Ensure all servers in opts are installed
      }

      local servers = opts.servers or {}
      servers = vim.tbl_extend('force', servers, opts.servers_no_install or {})
      opts.servers = servers

      -- Configure diagnostics
      vim.diagnostic.config(opts.diagnostics)

      -- Configure LSP servers
      local lspconfig = require 'lspconfig'
      for server, config in pairs(opts.servers) do
        config = vim.tbl_extend('force', {
          on_attach = function(client, bufnr)
            -- Attach keymaps
            local keymaps = require 'config.lsp_keymaps' -- Adjust the path as needed
            keymaps.on_attach(client, bufnr)
          end,
        }, config)
        config.capabilities = require('blink.cmp').get_lsp_capabilities(config.capabilities)

        -- Handle special setup functions
        if opts.setup and opts.setup[server] then
          if opts.setup[server](server, config) then
            goto continue
          end
        end

        lspconfig[server].setup(config)
        ::continue::
      end
    end,
  },

  -- Clangd extensions
  {
    'p00f/clangd_extensions.nvim',
    lazy = true,
    config = function() end,
  },

  -- ============================================================================
  -- CODE QUALITY (FORMATTING & LINTING)
  -- ============================================================================

  -- Code formatting
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = 'ConformInfo',
    keys = {
      {
        '<leader>cF',
        function()
          require('conform').format { formatters = { 'injected' }, timeout_ms = 3000 }
        end,
        mode = { 'n', 'v' },
        desc = 'Format Injected Langs',
      },
      {
        '<leader>uF',
        function()
          ConformOptions.format_on_save_enabled = not ConformOptions.format_on_save_enabled
          if ConformOptions.format_on_save_enabled then
            vim.notify('Format on Save Enabled', vim.log.levels.INFO)
          else
            vim.notify('Format on Save Disabled', vim.log.levels.WARN)
          end
        end,
        mode = { 'n' },
        desc = 'Enable/Disable Format on Save',
      },
    },
    opts = function()
      _G.ConformOptions = _G.ConformOptions or {}
      ConformOptions.format_on_save_enabled = true

      -- Prettier utility functions
      local supported_filetypes = {
        'css',
        'graphql',
        'handlebars',
        'html',
        'javascript',
        'javascriptreact',
        'json',
        'jsonc',
        'less',
        'markdown',
        'markdown.mdx',
        'scss',
        'typescript',
        'typescriptreact',
        'vue',
        'yaml',
      }

      local function has_prettier_config(ctx)
        vim.fn.system { 'prettier', '--find-config-path', ctx.filename }
        return vim.v.shell_error == 0
      end

      local function has_prettier_parser(ctx)
        local ft = vim.bo[ctx.buf].filetype
        -- default filetypes are always supported
        if vim.tbl_contains(supported_filetypes, ft) then
          return true
        end
        -- otherwise, check if a parser can be inferred
        local ret = vim.fn.system { 'prettier', '--file-info', ctx.filename }
        local ok, parser = pcall(function()
          return vim.fn.json_decode(ret).inferredParser
        end)
        return ok and parser and parser ~= vim.NIL
      end

      ---@type conform.setupOpts
      return {
        default_format_opts = {
          timeout_ms = 3000,
          async = false,
          quiet = false,
          lsp_format = 'fallback',
        },
        formatters_by_ft = {
          lua = { 'stylua' },
          python = { 'black' },
          toml = { 'taplo' },
          markdown = { 'prettier', 'markdownlint-cli2', 'markdown-toc' },
          ['markdown.mdx'] = { 'prettier', 'markdownlint-cli2', 'markdown-toc' },
          -- Prettier for web technologies
          css = { 'prettier' },
          graphql = { 'prettier' },
          handlebars = { 'prettier' },
          html = { 'prettier' },
          javascript = { 'prettier' },
          javascriptreact = { 'prettier' },
          json = { 'prettier' },
          jsonc = { 'prettier' },
          less = { 'prettier' },
          scss = { 'prettier' },
          typescript = { 'prettier' },
          typescriptreact = { 'prettier' },
          vue = { 'prettier' },
          yaml = { 'prettier' },
        },
        formatters = {
          injected = { options = { ignore_errors = true } },
          prettier = {
            condition = function(_, ctx)
              return has_prettier_parser(ctx)
            end,
          },
          ['markdown-toc'] = {
            condition = function(_, ctx)
              for _, line in ipairs(vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false)) do
                if line:find '<!%-%- toc %-%->' then
                  return true
                end
              end
            end,
          },
          ['markdownlint-cli2'] = {
            condition = function(_, ctx)
              local diag = vim.tbl_filter(function(d)
                return d.source == 'markdownlint'
              end, vim.diagnostic.get(ctx.buf))
              return #diag > 0
            end,
          },
        },
      }
    end,
    config = function(_, opts)
      require('conform').setup(opts)
      vim.api.nvim_create_autocmd('BufWritePre', {
        pattern = '*',
        callback = function(args)
          local conform = require 'conform'
          -- Check if formatting is available for this buffer
          local formatters = conform.list_formatters(args.buf)
          if #formatters > 0 and ConformOptions.format_on_save_enabled then
            conform.format { bufnr = args.buf }
          end
        end,
      })
    end,
  },

  -- Linting
  {
    'mfussenegger/nvim-lint',
    event = { 'BufReadPost', 'BufNewFile', 'BufWritePost' },
    opts = {
      events = { 'BufWritePost', 'BufReadPost', 'InsertLeave' },
      linters_by_ft = {
        fish = { 'fish' },
        cmake = { 'cmakelint' },
        dockerfile = { 'hadolint' },
        markdown = { 'markdownlint-cli2' },
      },
      linters = {},
    },
    config = function(_, opts)
      local lint = require 'lint'
      for name, linter in pairs(opts.linters) do
        if type(linter) == 'table' and type(lint.linters[name]) == 'table' then
          lint.linters[name] = vim.tbl_deep_extend('force', lint.linters[name], linter)
          if type(linter.prepend_args) == 'table' then
            lint.linters[name].args = lint.linters[name].args or {}
            vim.list_extend(lint.linters[name].args, linter.prepend_args)
          end
        else
          lint.linters[name] = linter
        end
      end
      lint.linters_by_ft = opts.linters_by_ft

      local function debounce(ms, fn)
        local timer = vim.uv.new_timer()
        return function(...)
          local argv = { ... }
          timer:start(ms, 0, function()
            timer:stop()
            vim.schedule_wrap(fn)(unpack(argv))
          end)
        end
      end

      local function lint_buffer()
        -- Use nvim-lint's logic first:
        -- * checks if linters exist for the full filetype first
        -- * otherwise will split filetype by "." and add all those linters
        -- * this differs from conform.nvim which only uses the first filetype that has a formatter
        local names = lint._resolve_linter_by_ft(vim.bo.filetype)

        -- Create a copy of the names table to avoid modifying the original.
        names = vim.list_extend({}, names)

        -- Add fallback linters.
        if #names == 0 then
          vim.list_extend(names, lint.linters_by_ft['_'] or {})
        end

        -- Add global linters.
        vim.list_extend(names, lint.linters_by_ft['*'] or {})

        -- Filter out linters that don't exist or don't match the condition.
        local ctx = { filename = vim.api.nvim_buf_get_name(0) }
        ctx.dirname = vim.fn.fnamemodify(ctx.filename, ':h')
        names = vim.tbl_filter(function(name)
          local linter = lint.linters[name]
          return linter and not (type(linter) == 'table' and linter.condition and not linter.condition(ctx))
        end, names)

        -- Run linters.
        if #names > 0 then
          lint.try_lint(names)
        end
      end

      vim.api.nvim_create_autocmd(opts.events, {
        group = vim.api.nvim_create_augroup('nvim-lint', { clear = true }),
        callback = debounce(100, lint_buffer),
      })
    end,
  },

  -- ============================================================================
  -- GIT INTEGRATION
  -- ============================================================================

  -- Git signs in the gutter
  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
      signs = {
        add = { text = '▎' },
        change = { text = '▎' },
        delete = { text = '' },
        topdelete = { text = '' },
        changedelete = { text = '▎' },
        untracked = { text = '▎' },
      },
      signs_staged = {
        add = { text = '▎' },
        change = { text = '▎' },
        delete = { text = '' },
        topdelete = { text = '' },
        changedelete = { text = '▎' },
      },
      on_attach = function(buffer)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
        end

        -- Navigation
        map('n', ']h', function()
          if vim.wo.diff then
            vim.cmd.normal { ']c', bang = true }
          else
            gs.nav_hunk 'next'
          end
        end, 'Next Hunk')
        map('n', '[h', function()
          if vim.wo.diff then
            vim.cmd.normal { '[c', bang = true }
          else
            gs.nav_hunk 'prev'
          end
        end, 'Prev Hunk')
        map('n', ']H', function()
          gs.nav_hunk 'last'
        end, 'Last Hunk')
        map('n', '[H', function()
          gs.nav_hunk 'first'
        end, 'First Hunk')

        -- Actions
        map({ 'n', 'v' }, '<leader>ghs', ':Gitsigns stage_hunk<CR>', 'Stage Hunk')
        map({ 'n', 'v' }, '<leader>ghr', ':Gitsigns reset_hunk<CR>', 'Reset Hunk')
        map('n', '<leader>ghS', gs.stage_buffer, 'Stage Buffer')
        map('n', '<leader>ghu', gs.undo_stage_hunk, 'Undo Stage Hunk')
        map('n', '<leader>ghR', gs.reset_buffer, 'Reset Buffer')
        map('n', '<leader>ghp', gs.preview_hunk_inline, 'Preview Hunk Inline')
        map('n', '<leader>ghb', function()
          gs.blame_line { full = true }
        end, 'Blame Line')
        map('n', '<leader>ghB', function()
          gs.blame()
        end, 'Blame Buffer')
        map('n', '<leader>ghd', gs.diffthis, 'Diff This')
        map('n', '<leader>ghD', function()
          gs.diffthis '~'
        end, 'Diff This ~')
        map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', 'GitSigns Select Hunk')
      end,
    },
    config = function(_, opts)
      require('gitsigns').setup(opts)

      -- Toggle for git signs
      Snacks.toggle({
        name = 'Git Signs',
        get = function()
          return require('gitsigns.config').config.signcolumn
        end,
        set = function(state)
          require('gitsigns').toggle_signs(state)
        end,
      }):map '<leader>uG'
    end,
  },

  -- ============================================================================
  -- SEARCH & NAVIGATION
  -- ============================================================================

  -- FZF-based fuzzy finder
  {
    'ibhagwan/fzf-lua',
    cmd = 'FzfLua',
    dependencies = { 'folke/trouble.nvim' },
    opts = function(_, opts)
      local fzf = require 'fzf-lua'
      local config = fzf.config
      local actions = fzf.actions

      -- Quickfix
      config.defaults.keymap.fzf['ctrl-q'] = 'select-all+accept'
      config.defaults.keymap.fzf['ctrl-u'] = 'half-page-up'
      config.defaults.keymap.fzf['ctrl-d'] = 'half-page-down'
      config.defaults.keymap.fzf['ctrl-x'] = 'jump'
      config.defaults.keymap.fzf['ctrl-f'] = 'preview-page-down'
      config.defaults.keymap.fzf['ctrl-b'] = 'preview-page-up'
      config.defaults.keymap.builtin['<c-f>'] = 'preview-page-down'
      config.defaults.keymap.builtin['<c-b>'] = 'preview-page-up'

      -- Trouble integration
      config.defaults.actions.files['ctrl-t'] = require('trouble.sources.fzf').actions.open

      -- Toggle root dir / cwd
      config.defaults.actions.files['alt-c'] = config.defaults.actions.files['ctrl-r']

      local img_previewer ---@type string[]?
      for _, v in ipairs {
        { cmd = 'ueberzug', args = {} },
        { cmd = 'chafa', args = { '{file}', '--format=symbols' } },
        { cmd = 'viu', args = { '-b' } },
      } do
        if vim.fn.executable(v.cmd) == 1 then
          img_previewer = vim.list_extend({ v.cmd }, v.args)
          break
        end
      end

      return {
        'default-title',
        fzf_colors = true,
        fzf_opts = {
          ['--no-scrollbar'] = true,
        },
        defaults = {
          formatter = 'path.dirname_first',
        },
        previewers = {
          builtin = {
            extensions = {
              ['png'] = img_previewer,
              ['jpg'] = img_previewer,
              ['jpeg'] = img_previewer,
              ['gif'] = img_previewer,
              ['webp'] = img_previewer,
            },
            ueberzug_scaler = 'fit_contain',
          },
        },
        -- Custom LazyVim option to configure vim.ui.select
        ui_select = function(fzf_opts, items)
          return vim.tbl_deep_extend('force', fzf_opts, {
            prompt = ' ',
            winopts = {
              title = ' ' .. vim.trim((fzf_opts.prompt or 'Select'):gsub('%s*:%s*$', '')) .. ' ',
              title_pos = 'center',
            },
          }, fzf_opts.kind == 'codeaction' and {
            winopts = {
              layout = 'vertical',
              -- height is number of items minus 15 lines for the preview, with a max of 80% screen height
              height = math.floor(math.min(vim.o.lines * 0.8 - 16, #items + 2) + 0.5) + 16,
              width = 0.5,
            },
          } or {
            winopts = {
              width = 0.5,
              -- height is number of items, with a max of 80% screen height
              height = math.floor(math.min(vim.o.lines * 0.8, #items + 2) + 0.5),
            },
          })
        end,
        winopts = {
          width = 0.8,
          height = 0.8,
          row = 0.5,
          col = 0.5,
          preview = {
            scrollchars = { '┃', '' },
          },
        },
        files = {
          cwd_prompt = false,
          actions = {
            ['alt-i'] = { actions.toggle_ignore },
            ['alt-h'] = { actions.toggle_hidden },
          },
        },
        grep = {
          actions = {
            ['alt-i'] = { actions.toggle_ignore },
            ['alt-h'] = { actions.toggle_hidden },
          },
        },
        lsp = {
          symbols = {
            symbol_hl = function(s)
              return 'TroubleIcon' .. s
            end,
            symbol_fmt = function(s)
              return s:lower() .. '\\t'
            end,
            child_prefix = false,
          },
          code_actions = {
            previewer = vim.fn.executable 'delta' == 1 and 'codeaction_native' or nil,
          },
        },
      }
    end,
    config = function(_, opts)
      if opts[1] == 'default-title' then
        -- use the same prompt for all pickers for profile `default-title` and
        -- profiles that use `default-title` as base profile
        local function fix(t)
          t.prompt = t.prompt ~= nil and ' ' or nil
          for _, v in pairs(t) do
            if type(v) == 'table' then
              fix(v)
            end
          end
          return t
        end
        opts = vim.tbl_deep_extend('force', fix(require 'fzf-lua.profiles.default-title'), opts)
        opts[1] = nil
      end
      require('fzf-lua').setup(opts)
    end,
    keys = {
      { '<c-j>', '<c-j>', ft = 'fzf', mode = 't', nowait = true },
      { '<c-k>', '<c-k>', ft = 'fzf', mode = 't', nowait = true },
      -- Buffer management
      { '<leader>,', '<cmd>FzfLua buffers sort_mru=true sort_lastused=true<cr>', desc = 'Switch Buffer' },
      { '<leader>:', '<cmd>FzfLua command_history<cr>', desc = 'Command History' },
      -- File finding
      { '<leader>fb', '<cmd>FzfLua buffers sort_mru=true sort_lastused=true<cr>', desc = 'Buffers' },
      { '<leader>ff', '<cmd>FzfLua files<cr>', desc = 'Find Files (cwd)' },
      { '<leader>fg', '<cmd>FzfLua git_files<cr>', desc = 'Find Files (git-files)' },
      { '<leader>fr', '<cmd>FzfLua oldfiles<cr>', desc = 'Recent' },
      -- Git
      { '<leader>gc', '<cmd>FzfLua git_commits<CR>', desc = 'Commits' },
      { '<leader>gs', '<cmd>FzfLua git_status<CR>', desc = 'Status' },
      -- Search
      { '<leader>s"', '<cmd>FzfLua registers<cr>', desc = 'Registers' },
      { '<leader>sa', '<cmd>FzfLua autocmds<cr>', desc = 'Auto Commands' },
      { '<leader>sb', '<cmd>FzfLua grep_curbuf<cr>', desc = 'Buffer' },
      { '<leader>sc', '<cmd>FzfLua command_history<cr>', desc = 'Command History' },
      { '<leader>sC', '<cmd>FzfLua commands<cr>', desc = 'Commands' },
      { '<leader>sd', '<cmd>FzfLua diagnostics_document<cr>', desc = 'Document Diagnostics' },
      { '<leader>sD', '<cmd>FzfLua diagnostics_workspace<cr>', desc = 'Workspace Diagnostics' },
      { '<leader>sg', '<cmd>FzfLua live_grep<cr>', desc = 'Grep (cwd)' },
      { '<leader>sh', '<cmd>FzfLua help_tags<cr>', desc = 'Help Pages' },
      { '<leader>sH', '<cmd>FzfLua highlights<cr>', desc = 'Search Highlight Groups' },
      { '<leader>sj', '<cmd>FzfLua jumps<cr>', desc = 'Jumplist' },
      { '<leader>sk', '<cmd>FzfLua keymaps<cr>', desc = 'Key Maps' },
      { '<leader>sl', '<cmd>FzfLua loclist<cr>', desc = 'Location List' },
      { '<leader>sM', '<cmd>FzfLua man_pages<cr>', desc = 'Man Pages' },
      { '<leader>sm', '<cmd>FzfLua marks<cr>', desc = 'Jump to Mark' },
      { '<leader>sR', '<cmd>FzfLua resume<cr>', desc = 'Resume' },
      { '<leader>sq', '<cmd>FzfLua quickfix<cr>', desc = 'Quickfix List' },
      { '<leader>sW', '<cmd>FzfLua grep_cword<cr>', desc = 'Word (cwd)' },
      { '<leader>sW', '<cmd>FzfLua grep_visual<cr>', mode = 'v', desc = 'Selection (cwd)' },
      -- LSP symbols
      {
        '<leader>ss',
        function()
          return require('fzf-lua').lsp_document_symbol
        end,
        desc = 'Goto Symbol',
      },
      {
        '<leader>sS',
        function()
          return require('fzf-lua').lsp_live_workspace_symbols
        end,
        desc = 'Goto Symbol (Workspace)',
      },
    },
  },

  -- Enhanced LSP keybindings for FZF-lua
  {
    'neovim/nvim-lspconfig',
    optional = true,
    opts = function()
      local keys = require('config.lsp_keymaps').get()
      vim.list_extend(keys, {
        { 'gd', '<cmd>FzfLua lsp_definitions     jump1=true ignore_current_line=true<cr>', desc = 'Goto Definition', has = 'definition' },
        { 'gr', '<cmd>FzfLua lsp_references      jump1=true ignore_current_line=true<cr>', desc = 'References', nowait = true },
        { 'gI', '<cmd>FzfLua lsp_implementations jump1=true ignore_current_line=true<cr>', desc = 'Goto Implementation' },
        { 'gy', '<cmd>FzfLua lsp_typedefs        jump1=true ignore_current_line=true<cr>', desc = 'Goto T[y]pe Definition' },
      })
    end,
  },

  -- Trouble diagnostics
  {
    'folke/trouble.nvim',
    cmd = { 'Trouble' },
    opts = {
      modes = {
        lsp = {
          win = { position = 'right' },
        },
      },
    },
    keys = {
      { '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>', desc = 'Diagnostics (Trouble)' },
      { '<leader>xX', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', desc = 'Buffer Diagnostics (Trouble)' },
      { '<leader>cs', '<cmd>Trouble symbols toggle<cr>', desc = 'Symbols (Trouble)' },
      { '<leader>cS', '<cmd>Trouble lsp toggle<cr>', desc = 'LSP references/definitions/... (Trouble)' },
      { '<leader>xL', '<cmd>Trouble loclist toggle<cr>', desc = 'Location List (Trouble)' },
      { '<leader>xQ', '<cmd>Trouble qflist toggle<cr>', desc = 'Quickfix List (Trouble)' },
      {
        '[q',
        function()
          if require('trouble').is_open() then
            require('trouble').prev { skip_groups = true, jump = true }
          else
            local ok, err = pcall(vim.cmd.cprev)
            if not ok then
              vim.notify(err, vim.log.levels.ERROR)
            end
          end
        end,
        desc = 'Previous Trouble/Quickfix Item',
      },
      {
        ']q',
        function()
          if require('trouble').is_open() then
            require('trouble').next { skip_groups = true, jump = true }
          else
            local ok, err = pcall(vim.cmd.cnext)
            if not ok then
              vim.notify(err, vim.log.levels.ERROR)
            end
          end
        end,
        desc = 'Next Trouble/Quickfix Item',
      },
    },
  },

  -- TODO comments highlighting and navigation
  {
    'folke/todo-comments.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
    cmd = { 'TodoTrouble', 'TodoTelescope' },
    opts = {},
    keys = {
      {
        ']t',
        function()
          require('todo-comments').jump_next()
        end,
        desc = 'Next Todo Comment',
      },
      {
        '[t',
        function()
          require('todo-comments').jump_prev()
        end,
        desc = 'Previous Todo Comment',
      },
      { '<leader>xt', '<cmd>Trouble todo toggle<cr>', desc = 'Todo (Trouble)' },
      { '<leader>xT', '<cmd>Trouble todo toggle filter = {tag = {TODO,FIX,FIXME}}<cr>', desc = 'Todo/Fix/Fixme (Trouble)' },
      {
        '<leader>st',
        function()
          require('todo-comments.fzf').todo()
        end,
        desc = 'Todo',
      },
      {
        '<leader>sT',
        function()
          require('todo-comments.fzf').todo { keywords = { 'TODO', 'FIX', 'FIXME' } }
        end,
        desc = 'Todo/Fix/Fixme',
      },
    },
  },

  -- Search and replace across project
  {
    'MagicDuck/grug-far.nvim',
    cmd = 'GrugFar',
    opts = { headerMaxWidth = 80 },
    keys = {
      {
        '<leader>sr',
        function()
          local grug = require 'grug-far'
          local ext = vim.bo.buftype == '' and vim.fn.expand '%:e'
          grug.open {
            transient = true,
            prefills = {
              filesFilter = ext and ext ~= '' and '*.' .. ext or nil,
            },
          }
        end,
        mode = { 'n', 'v' },
        desc = 'Search and Replace',
      },
    },
  },
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

  -- ============================================================================
  -- FILE MANAGEMENT & SESSIONS
  -- ============================================================================

  -- Mini file manager
  {
    'echasnovski/mini.files',
    keys = {
      {
        '<leader>fm',
        function()
          require('mini.files').open(vim.api.nvim_buf_get_name(0), true)
        end,
        desc = 'Open mini.files (Directory of Current File)',
      },
      {
        '<leader>fM',
        function()
          require('mini.files').open(vim.uv.cwd(), true)
        end,
        desc = 'Open mini.files (cwd)',
      },
    },
    opts = {
      windows = {
        preview = true,
        width_focus = 30,
        width_preview = 30,
      },
      options = {
        -- Whether to use for editing directories
        -- Disabled by default in LazyVim because neo-tree is used for that
        use_as_default_explorer = false,
      },
    },
    config = function(_, opts)
      require('mini.files').setup(opts)

      local show_dotfiles = true
      local filter_show = function(fs_entry)
        return true
      end
      local filter_hide = function(fs_entry)
        return not vim.startswith(fs_entry.name, '.')
      end

      local toggle_dotfiles = function()
        show_dotfiles = not show_dotfiles
        local new_filter = show_dotfiles and filter_show or filter_hide
        require('mini.files').refresh { content = { filter = new_filter } }
      end

      local map_split = function(buf_id, lhs, direction, close_on_file)
        local rhs = function()
          local new_target_window
          local cur_target_window = require('mini.files').get_explorer_state().target_window
          if cur_target_window ~= nil then
            vim.api.nvim_win_call(cur_target_window, function()
              vim.cmd('belowright ' .. direction .. ' split')
              new_target_window = vim.api.nvim_get_current_win()
            end)

            require('mini.files').set_target_window(new_target_window)
            require('mini.files').go_in { close_on_file = close_on_file }
          end
        end

        local desc = 'Open in ' .. direction .. ' split'
        if close_on_file then
          desc = desc .. ' and close'
        end
        vim.keymap.set('n', lhs, rhs, { buffer = buf_id, desc = desc })
      end

      local files_set_cwd = function()
        local cur_entry_path = MiniFiles.get_fs_entry().path
        local cur_directory = vim.fs.dirname(cur_entry_path)
        if cur_directory ~= nil then
          vim.fn.chdir(cur_directory)
        end
      end

      vim.api.nvim_create_autocmd('User', {
        pattern = 'MiniFilesBufferCreate',
        callback = function(args)
          local buf_id = args.data.buf_id

          vim.keymap.set('n', opts.mappings and opts.mappings.toggle_hidden or 'g.', toggle_dotfiles, { buffer = buf_id, desc = 'Toggle hidden files' })

          vim.keymap.set('n', opts.mappings and opts.mappings.change_cwd or 'gc', files_set_cwd, { buffer = args.data.buf_id, desc = 'Set cwd' })

          map_split(buf_id, opts.mappings and opts.mappings.go_in_horizontal or '<C-w>s', 'horizontal', false)
          map_split(buf_id, opts.mappings and opts.mappings.go_in_vertical or '<C-w>v', 'vertical', false)
          map_split(buf_id, opts.mappings and opts.mappings.go_in_horizontal_plus or '<C-w>S', 'horizontal', true)
          map_split(buf_id, opts.mappings and opts.mappings.go_in_vertical_plus or '<C-w>V', 'vertical', true)
        end,
      })

      vim.api.nvim_create_autocmd('User', {
        pattern = 'MiniFilesActionRename',
        callback = function(event)
          Snacks.rename.on_rename_file(event.data.from, event.data.to)
        end,
      })
    end,
  },

  -- Surround text objects
  {
    'echasnovski/mini.surround',
    keys = function(_, keys)
      -- Mini surround configuration
      local mini_surround_opts = {
        mappings = {
          add = 'gsa', -- Add surrounding in Normal and Visual modes
          delete = 'gsd', -- Delete surrounding
          find = 'gsf', -- Find surrounding (to the right)
          find_left = 'gsF', -- Find surrounding (to the left)
          highlight = 'gsh', -- Highlight surrounding
          replace = 'gsr', -- Replace surrounding
          update_n_lines = 'gsn', -- Update `n_lines`
        },
      }

      -- Populate the keys based on the user's options
      local mappings = {
        { mini_surround_opts.mappings.add, desc = 'Add Surrounding', mode = { 'n', 'v' } },
        { mini_surround_opts.mappings.delete, desc = 'Delete Surrounding' },
        { mini_surround_opts.mappings.find, desc = 'Find Right Surrounding' },
        { mini_surround_opts.mappings.find_left, desc = 'Find Left Surrounding' },
        { mini_surround_opts.mappings.highlight, desc = 'Highlight Surrounding' },
        { mini_surround_opts.mappings.replace, desc = 'Replace Surrounding' },
        { mini_surround_opts.mappings.update_n_lines, desc = 'Update `MiniSurround.config.n_lines`' },
      }
      mappings = vim.tbl_filter(function(m)
        return m[1] and #m[1] > 0
      end, mappings)
      return vim.list_extend(mappings, keys)
    end,
    opts = {
      mappings = {
        add = 'gsa', -- Add surrounding in Normal and Visual modes
        delete = 'gsd', -- Delete surrounding
        find = 'gsf', -- Find surrounding (to the right)
        find_left = 'gsF', -- Find surrounding (to the left)
        highlight = 'gsh', -- Highlight surrounding
        replace = 'gsr', -- Replace surrounding
        update_n_lines = 'gsn', -- Update `n_lines`
      },
    },
  },

  -- Session persistence
  {
    'folke/persistence.nvim',
    event = 'BufReadPre',
    opts = {},
    keys = {
      {
        '<leader>qs',
        function()
          require('persistence').load()
        end,
        desc = 'Restore Session',
      },
      {
        '<leader>qS',
        function()
          require('persistence').select()
        end,
        desc = 'Select Session',
      },
      {
        '<leader>ql',
        function()
          require('persistence').load { last = true }
        end,
        desc = 'Restore Last Session',
      },
      {
        '<leader>qd',
        function()
          require('persistence').stop()
        end,
        desc = "Don't Save Current Session",
      },
    },
  },

  -- ============================================================================
  -- SNIPPETS
  -- ============================================================================

  -- Disable builtin snippet support in favor of LuaSnip
  { 'garymjr/nvim-snippets', enabled = false },

  -- LuaSnip snippet engine
  {
    'L3MON4D3/LuaSnip',
    lazy = true,
    dependencies = {
      {
        'rafamadriz/friendly-snippets',
        config = function()
          require('luasnip.loaders.from_vscode').lazy_load()
          require('luasnip.loaders.from_vscode').lazy_load { paths = { vim.fn.stdpath 'config' .. '/snippets' } }
        end,
      },
    },
    opts = {
      history = true,
      delete_check_events = 'TextChanged',
    },
  },
}
