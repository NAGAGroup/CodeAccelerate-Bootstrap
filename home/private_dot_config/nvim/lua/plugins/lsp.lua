return {
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
}
