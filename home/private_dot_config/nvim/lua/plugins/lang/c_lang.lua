return {
  -- ============================================================================
  -- LSP & COMPLETION
  -- ============================================================================
  {
    -- Main LSP Configuration
    'neovim/nvim-lspconfig',
    opts = {
      -- LSP server configurations
      servers_no_install = {},
      servers = {
        -- C/C++ Language Server
        clangd = {
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
      },
      setup = {
        clangd = function(opts)
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
      ensure_installed = {
        -- Linters
        'cmakelint',
        -- Debug adapters
        'codelldb',
        -- Tools
        'cmakelang',
      },
    },
  },

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
    opts = {
      formatters_by_ft = {},
      formatters = {},
    },
  },

  -- Linting
  {
    'mfussenegger/nvim-lint',
    opts = {
      linters_by_ft = {
        cmake = { 'cmakelint' },
      },
      linters = {},
    },
  },

  -- Debug Adapter Protocol
  {
    'mfussenegger/nvim-dap',
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

  -- mason.nvim integration
  {
    'jay-babu/mason-nvim-dap.nvim',
    opts = {
      -- You'll need to check that you have the required things installed
      -- online, please don't ask me how to install them :)
      ensure_installed = {
        -- Update this to ensure that you have the debuggers for the langs you want
      },
    },
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
  -- EDITOR CORE
  -- ============================================================================

  -- Treesitter syntax highlighting and parsing
  {
    'nvim-treesitter/nvim-treesitter',
    ---@type TSConfig
    ---@diagnostic disable-next-line: missing-fields
    opts = {
      ensure_installed = {
        'c',
        'cpp',
        'cmake',
      },
    },
  },
}
