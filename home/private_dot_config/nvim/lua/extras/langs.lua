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

return {

  -- Add C/C++ to treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    opts = { ensure_installed = { 'cpp' } },
  },

  {
    'p00f/clangd_extensions.nvim',
    lazy = true,
    opts = clangd_opts,
    config = function() end,
  },

  -- Correctly setup lspconfig for clangd 🚀
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        -- Ensure mason installs the server
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
      },
      setup = {
        clangd = function(_, opts)
          require('clangd_extensions').setup(vim.tbl_deep_extend('force', clangd_opts or {}, { server = opts }))
          return false
        end,
      },
    },
  },

  {
    'mfussenegger/nvim-dap',
    dependencies = {
      -- Ensure C/C++ debugger is installed
      'mason-org/mason.nvim',
      opts = { ensure_installed = { 'codelldb' } },
    },
    opts = function()
      local dap = require 'dap'
      if not dap.adapters['codelldb'] then
        require('dap').adapters['codelldb'] = {
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
          },
          {
            type = 'codelldb',
            request = 'attach',
            name = 'Attach to process',
            pid = require('dap.utils').pick_process,
            cwd = '${workspaceFolder}',
          },
        }
      end
    end,
  },

  {
    'nvim-treesitter/nvim-treesitter',
    opts = { ensure_installed = { 'cmake' } },
  },
  {
    'mfussenegger/nvim-lint',
    opts = {
      linters_by_ft = {
        cmake = { 'cmakelint' },
      },
    },
  },
  {
    'mason.nvim',
    opts = { ensure_installed = { 'cmakelang', 'cmakelint' } },
  },
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        neocmake = {},
      },
    },
  },
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
  {
    'nvim-treesitter/nvim-treesitter',
    opts = { ensure_installed = { 'dockerfile' } },
  },
  {
    'mason.nvim',
    opts = { ensure_installed = { 'hadolint' } },
  },
  {
    'mfussenegger/nvim-lint',
    opts = {
      linters_by_ft = {
        dockerfile = { 'hadolint' },
      },
    },
  },
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        dockerls = {},
        docker_compose_language_service = {},
      },
    },
  },
  -- Treesitter git support
  {
    'nvim-treesitter/nvim-treesitter',
    opts = { ensure_installed = { 'git_config', 'gitcommit', 'git_rebase', 'gitignore', 'gitattributes' } },
  },

  {
    'stevearc/conform.nvim',
    opts = {
      formatters = {
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
      formatters_by_ft = {
        ['markdown'] = { 'prettier', 'markdownlint-cli2', 'markdown-toc' },
        ['markdown.mdx'] = { 'prettier', 'markdownlint-cli2', 'markdown-toc' },
      },
    },
  },
  {
    'mason-org/mason.nvim',
    opts = { ensure_installed = { 'markdownlint-cli2', 'markdown-toc' } },
  },
  {
    'mfussenegger/nvim-lint',
    opts = {
      linters_by_ft = {
        markdown = { 'markdownlint-cli2' },
      },
    },
  },
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        marksman = {},
      },
    },
  },

  -- Markdown preview
  -- {
  --   'iamcco/markdown-preview.nvim',
  --   cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
  --   build = function()
  --     require('lazy').load { plugins = { 'markdown-preview.nvim' } }
  --     vim.fn['mkdp#util#install']()
  --   end,
  --   keys = {
  --     {
  --       '<leader>cp',
  --       ft = 'markdown',
  --       '<cmd>MarkdownPreviewToggle<cr>',
  --       desc = 'Markdown Preview',
  --     },
  --   },
  --   config = function()
  --     vim.cmd [[do FileType]]
  --   end,
  -- },
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers_no_install = {
        nushell = {},
      },
    },
  },
  {
    'nvim-treesitter/nvim-treesitter',
    opts = { ensure_installed = { 'nu' } },
  },
  -- {
  --   'stevearc/conform.nvim',
  --     --   opts = function()
  --     local opts = {
  --       formatters_by_ft = {
  --         ['nu'] = { 'nufmt' },
  --       },
  --     }
  --
  --     if vim.fn.executable 'nufmt' == 0 then
  --       return nil
  --     end
  --
  --     return opts
  --   end,
  -- },

  -- add json to treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    opts = { ensure_installed = { 'json5' } },
  },

  -- yaml schema support
  {
    'b0o/SchemaStore.nvim',
    lazy = true,
    version = false, -- last release is way too old
  },

  -- correctly setup lspconfig
  {
    'neovim/nvim-lspconfig',
    opts = {
      -- make sure mason installs the server
      servers = {
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
      },
    },
  },

  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        taplo = {},
      },
    },
  },
  {
    'stevearc/conform.nvim',
    opts = {
      formatters_by_ft = {
        toml = { 'taplo' },
      },
    },
  },

  -- yaml schema support
  {
    'b0o/SchemaStore.nvim',
    lazy = true,
    version = false, -- last release is way too old
  },

  -- correctly setup lspconfig
  {
    'neovim/nvim-lspconfig',
    opts = {
      -- make sure mason installs the server
      servers = {
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
    },
  },
}
