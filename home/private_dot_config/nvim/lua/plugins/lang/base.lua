local function has_prettier_config(ctx)
  vim.fn.system { 'prettier', '--find-config-path', ctx.filename }
  return vim.v.shell_error == 0
end

local function has_prettier_parser(ctx)
  local ft = vim.bo[ctx.buf].filetype
  -- default filetypes are always supported
  if
    vim.tbl_contains({
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
    }, ft)
  then
    return true
  end
  -- otherwise, check if a parser can be inferred
  local ret = vim.fn.system { 'prettier', '--file-info', ctx.filename }
  local ok, parser = pcall(function()
    return vim.fn.json_decode(ret).inferredParser
  end)
  return ok and parser and parser ~= vim.NIL
end
return {
  -- ============================================================================
  -- LSP & COMPLETION
  -- ============================================================================
  {
    -- Main LSP Configuration
    'neovim/nvim-lspconfig',
    opts = {
      -- LSP server configurations
      servers = {
        lua_ls = {
          settings = {
            Lua = {
              workspace = {
                checkThirdParty = false,
                library = {
                  [vim.fn.expand '$VIMRUNTIME/lua'] = true,
                  [vim.fn.expand '$VIMRUNTIME/lua/vim/lsp'] = true,
                  [vim.fn.stdpath 'data' .. '/lazy/lazy.nvim/lua/lazy'] = true,
                },
                maxPreload = 100000,
                preloadFileSize = 10000,
              },
              codeLens = {
                enable = false, -- Disable for better performance
              },
              completion = {
                callSnippet = 'Replace',
              },
              hint = {
                enable = false, -- Disable inlay hints for better performance
                paramType = false,
              },
              telemetry = {
                enable = false, -- Disable telemetry for better performance
              },
              diagnostics = {
                disable = { 'missing-fields' }, -- Reduce noisy diagnostics
                globals = { 'vim' }, -- Recognize vim as global
              },
              format = {
                enable = false, -- Use external formatter instead
              },
            },
          },
        },
        -- Other language servers
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
      ensure_installed = {
        -- Formatters
        'stylua',
        'shfmt',
        'prettier',
        'black',
        'markdownlint-cli2',
        'markdown-toc',
      },
    },
  },

  -- ============================================================================
  -- CODE QUALITY (FORMATTING & LINTING)
  -- ============================================================================

  -- Code formatting
  {
    'stevearc/conform.nvim',
    opts = {
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
    },
  },

  -- Linting
  {
    'mfussenegger/nvim-lint',
    opts = {
      linters_by_ft = {
        markdown = { 'markdownlint-cli2' },
      },
    },
  },

  -- Debug Adapter Protocol
  {
    'mfussenegger/nvim-dap',
    opts = function() end,
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
        'bash',
        'css',
        'diff',
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
    },
  },

  -- Markdown preview and rendering
  {
    'nvim-treesitter/nvim-treesitter',
    dependencies = { 'OXY2DEV/markview.nvim' },
    lazy = false,
  },
  {
    'OXY2DEV/markview.nvim',
    lazy = false,

    -- For `nvim-treesitter` users.
    priority = 49,

    -- For blink.cmp's completion
    -- source
    dependencies = {
      'saghen/blink.cmp',
    },
    opts = {
      preview = {
        filetypes = { 'markdown', 'quarto', 'rmd', 'codecompanion' },
        ignore_buftypes = {},
      },
    },
  },
}
