--[[
=====================================================================
                    Neovim Plugins - Coding & Development
=====================================================================

This file configures all plugins related to code editing, including:
  - LSP (Language Server Protocol) configuration
  - Code completion (blink.cmp)
  - Code formatting (conform.nvim)
  - Code linting (nvim-lint)
  - Debugging (nvim-dap)
  - Refactoring tools

PLUGIN OVERVIEW:

  LSP & Completion:
    - nvim-lspconfig    : LSP client configuration
    - mason.nvim        : LSP/tool installer
    - mason-lspconfig   : Bridge between Mason and lspconfig
    - mason-tool-installer : Ensures tools are installed
    - blink.cmp         : Fast completion engine (Rust-based)
    - fidget.nvim       : LSP progress indicator

  Code Quality:
    - conform.nvim      : Code formatting (async, supports multiple formatters)
    - nvim-lint         : Linting (async, integrates with diagnostics)

  Debugging:
    - nvim-dap          : Debug Adapter Protocol client
    - nvim-dap-ui       : UI for debugging
    - nvim-dap-virtual-text : Inline variable values during debugging
    - mason-nvim-dap    : Mason integration for debug adapters

  Refactoring:
    - refactoring.nvim  : Extract functions, inline variables, etc.

LSP SERVERS (configured in opts.servers):
  - lua_ls         : Lua (with Neovim API support)
  - clangd         : C/C++ (with clangd_extensions)
  - neocmake       : CMake
  - jsonls         : JSON (with schemastore)
  - yamlls         : YAML (with schemastore)
  - taplo          : TOML
  - marksman       : Markdown
  - dockerls       : Dockerfile
  - docker_compose_language_service : docker-compose.yml
  - nushell        : Nushell (system-installed, not via Mason)

FORMATTERS (configured in conform.nvim):
  - stylua         : Lua
  - black          : Python
  - prettier       : Web (JS, TS, CSS, HTML, JSON, YAML, Markdown)
  - taplo          : TOML (via LSP)
  - markdownlint-cli2 : Markdown linting/fixing

LINTERS (configured in nvim-lint):
  - cmakelint      : CMake
  - hadolint       : Dockerfile
  - markdownlint-cli2 : Markdown
  - nu             : Nushell

KEY MAPPINGS (defined in config/lsp_keymaps.lua):
  gd         : Go to definition
  gr         : Find references
  gI         : Go to implementation
  gy         : Go to type definition
  K          : Hover documentation
  <leader>ca : Code action
  <leader>cr : Rename symbol
  <leader>cf : Format (defined in config/keymaps.lua)
  <leader>cm : Open Mason

DEBUG MAPPINGS (defined here):
  <leader>db : Toggle breakpoint
  <leader>dc : Continue/Start debugging
  <leader>di : Step into
  <leader>do : Step out
  <leader>dO : Step over
  <leader>du : Toggle DAP UI

REFACTORING MAPPINGS:
  <leader>r  : Refactoring prefix
  <leader>rs : Select refactoring (visual mode)
  <leader>ri : Inline variable
  <leader>rf : Extract function (visual mode)
  <leader>rx : Extract variable (visual mode)

@see config.lsp_keymaps for LSP keybindings
@see https://github.com/neovim/nvim-lspconfig for LSP server configs
]]

-- =============================================================================
-- ICON DEFINITIONS
-- =============================================================================
-- These icons are used throughout the coding plugins for consistent UI

local icons = {
  -- Miscellaneous icons
  misc = {
    dots = '󰇘',
  },
  -- Filetype-specific icons
  ft = {
    octo = '', -- GitHub Octo plugin
  },
  -- Debug Adapter Protocol icons
  dap = {
    Stopped = { '󰁕 ', 'DiagnosticWarn', 'DapStoppedLine' },
    Breakpoint = ' ',
    BreakpointCondition = ' ',
    BreakpointRejected = { ' ', 'DiagnosticError' },
    LogPoint = '.>',
  },
  -- Diagnostic severity icons (used in signs and virtual text)
  diagnostics = {
    Error = ' ',
    Warn = ' ',
    Hint = ' ',
    Info = ' ',
  },
  -- Git status icons
  git = {
    added = ' ',
    modified = ' ',
    removed = ' ',
  },
  -- Completion item kind icons (for LSP completion)
  kinds = {
    Array = ' ',
    Boolean = '󰨙 ',
    Class = ' ',
    Codeium = '󰘦 ',
    Color = ' ',
    Control = ' ',
    Collapsed = ' ',
    Constant = '󰏿 ',
    Constructor = ' ',
    Copilot = ' ',
    Enum = ' ',
    EnumMember = ' ',
    Event = ' ',
    Field = ' ',
    File = ' ',
    Folder = ' ',
    Function = '󰊕 ',
    Interface = ' ',
    Key = ' ',
    Keyword = ' ',
    Method = '󰊕 ',
    Module = ' ',
    Namespace = '󰦮 ',
    Null = ' ',
    Number = '󰎠 ',
    Object = ' ',
    Operator = ' ',
    Package = ' ',
    Property = ' ',
    Reference = ' ',
    Snippet = '󱄽 ',
    String = ' ',
    Struct = '󰆼 ',
    Supermaven = ' ',
    TabNine = '󰏚 ',
    Text = ' ',
    TypeParameter = ' ',
    Unit = ' ',
    Value = ' ',
    Variable = '󰀫 ',
  },
}

return {
  -- ============================================================================
  -- LSP & COMPLETION
  -- ============================================================================

  --[[
    nvim-lspconfig - LSP Configuration
    
    This is the main LSP configuration hub. It:
    - Configures language servers with appropriate settings
    - Sets up diagnostics display
    - Attaches keymaps when LSP connects to a buffer
    - Integrates with Mason for automatic server installation
    
    The configuration uses a declarative approach where servers are defined
    in opts.servers and tools in opts.ensure_installed.
  ]]
  {
    'neovim/nvim-lspconfig',
    -- Allow other plugins to extend these tables
    opts_extend = {
      'servers_no_install', -- Servers not installed via Mason
      'ensure_installed',   -- Tools to install via Mason
    },
    dependencies = {
      -- Mason - LSP/Tool Installer
      -- Provides a UI for installing LSP servers, formatters, linters, and DAP adapters
      -- Must be loaded before mason-lspconfig
      {
        'mason-org/mason.nvim',
        cmd = 'Mason',
        keys = { { '<leader>cm', '<cmd>Mason<cr>', desc = 'Mason' } },
        opts = {},
      },
      -- Bridge between Mason and lspconfig
      -- Automatically configures servers installed via Mason
      'mason-org/mason-lspconfig.nvim',
      -- Ensures specified tools are installed
      -- Runs on startup to install missing tools
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- Fidget - LSP Progress Indicator
      -- Shows LSP indexing/loading progress in the corner
      { 'j-hui/fidget.nvim', opts = {} },

      -- Blink.cmp provides enhanced LSP capabilities
      'saghen/blink.cmp',
    },
    opts = {
      -- Diagnostic configuration
      diagnostics = {
        float = { border = 'rounded', source = 'if_many' },
        underline = { severity = vim.diagnostic.severity.ERROR },
        virtual_text = {
          source = 'if_many',
          spacing = 4,
          prefix = '●',
          format = function(diagnostic)
            local diagnostic_message = {
              [vim.diagnostic.severity.ERROR] = diagnostic.message,
              [vim.diagnostic.severity.WARN] = diagnostic.message,
              [vim.diagnostic.severity.INFO] = diagnostic.message,
              [vim.diagnostic.severity.HINT] = diagnostic.message,
            }
            return diagnostic_message[diagnostic.severity]
          end,
        },
        update_in_insert = false,
        severity_sort = true,
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = icons.diagnostics.Error,
            [vim.diagnostic.severity.WARN] = icons.diagnostics.Warn,
            [vim.diagnostic.severity.HINT] = icons.diagnostics.Hint,
            [vim.diagnostic.severity.INFO] = icons.diagnostics.Info,
          },
        },
      },

      -- ==========================================================================
      -- LSP SERVERS (all in one place)
      -- ==========================================================================
      servers_no_install = {
        -- Servers not installed via Mason (system-provided)
        nushell = {},
      },

      servers = {
        -- Lua
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
              codeLens = { enable = false },
              completion = { callSnippet = 'Replace' },
              hint = { enable = false, paramType = false },
              telemetry = { enable = false },
              diagnostics = { disable = { 'missing-fields' }, globals = { 'vim' } },
              format = { enable = false },
            },
          },
        },

        -- C/C++
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
            )(fname) or require('lspconfig.util').root_pattern('compile_commands.json', 'compile_flags.txt')(fname) or require('lspconfig.util').find_git_ancestor(fname)
          end,
          capabilities = { offsetEncoding = { 'utf-16' } },
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

        -- CMake
        neocmake = {},

        -- JSON (with schemastore)
        jsonls = {
          on_new_config = function(new_config)
            new_config.settings.json.schemas = new_config.settings.json.schemas or {}
            vim.list_extend(new_config.settings.json.schemas, require('schemastore').json.schemas())
          end,
          settings = {
            json = { format = { enable = true }, validate = { enable = true } },
          },
        },

        -- YAML (with schemastore)
        yamlls = {
          capabilities = {
            textDocument = {
              foldingRange = { dynamicRegistration = false, lineFoldingOnly = true },
            },
          },
          on_new_config = function(new_config)
            new_config.settings.yaml.schemas = vim.tbl_deep_extend('force', new_config.settings.yaml.schemas or {}, require('schemastore').yaml.schemas())
          end,
          settings = {
            redhat = { telemetry = { enabled = false } },
            yaml = {
              keyOrdering = false,
              format = { enable = true },
              validate = true,
              schemaStore = { enable = false, url = '' },
            },
          },
        },

        -- TOML
        taplo = {},

        -- Markdown
        marksman = {},

        -- Docker
        dockerls = {},
        docker_compose_language_service = {},
      },

      -- Custom setup functions for specific servers
      setup = {
        clangd = function(_, opts)
          local clangd_ext_opts = {
            inlay_hints = { inline = false },
            ast = {
              role_icons = {
                type = '',
                declaration = '',
                expression = '',
                specifier = '',
                statement = '',
                ['template argument'] = '',
              },
              kind_icons = {
                Compound = '',
                Recovery = '',
                TranslationUnit = '',
                PackExpansion = '',
                TemplateTypeParm = '',
                TemplateTemplateParm = '',
                TemplateParamObject = '',
              },
            },
          }
          require('clangd_extensions').setup(vim.tbl_deep_extend('force', clangd_ext_opts, { server = opts }))
          return false -- Let mason-lspconfig handle the server setup
        end,
      },

      -- Tools to install via Mason (formatters, linters, DAP)
      ensure_installed = {
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
        -- DAP
        'codelldb',
        -- Tools
        'cmakelang',
      },
    },
    config = function(_, opts)
      -- Brief aside: **What is LSP?**
      --
      -- LSP is an initialism you've probably heard, but might not understand what it is.
      --
      -- LSP stands for Language Server Protocol. It's a protocol that helps editors
      -- and language tooling communicate in a standardized fashion.
      --
      -- In general, you have a "server" which is some tool built to understand a particular
      -- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc.). These Language Servers
      -- (sometimes called LSP servers, but that's kind of like ATM Machine) are standalone
      -- processes that communicate with some "client" - in this case, Neovim!
      --
      -- LSP provides Neovim with features like:
      --  - Go to definition
      --  - Find references
      --  - Autocompletion
      --  - Symbol Search
      --  - and more!
      --
      -- Thus, Language Servers are external tools that must be installed separately from
      -- Neovim. This is where `mason` and related plugins come into play.
      --
      -- If you're wondering about lsp vs treesitter, you can check out the wonderfully
      -- and elegantly composed help section, `:help lsp-vs-treesitter`

      --  This function gets run when an LSP attaches to a particular buffer.
      --    That is to say, every time a new file is opened that is associated with
      --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
      --    function will be executed to configure the current buffer
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local function lazyvim_keymaps(client, bufnr)
            local keymaps = require 'config.lsp_keymaps'
            keymaps.on_attach(client, bufnr)
          end
          lazyvim_keymaps(vim.lsp.get_client_by_id(event.data.client_id), event.buf)

          -- This function resolves a difference between neovim nightly (version 0.11) and stable (version 0.10)
          ---@param client vim.lsp.Client
          ---@param method vim.lsp.protocol.Method
          ---@param bufnr? integer some lsp support methods only in specific files
          ---@return boolean
          local function client_supports_method(client, method, bufnr)
            if vim.fn.has 'nvim-0.11' == 1 then
              return client:supports_method(method, bufnr)
            else
              return client.supports_method(method, { bufnr = bufnr })
            end
          end

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          -- Enable inlay hints by default if the language server supports them
          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
            vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
          end
        end,
      })

      local function set_vim_diagnostic_config()
        -- Diagnostic Config
        -- See :help vim.diagnostic.Opts
        vim.diagnostic.config(opts.diagnostics)
      end
      set_vim_diagnostic_config()

      -- LSP servers and clients are able to communicate to each other what features they support.
      --  By default, Neovim doesn't support everything that is in the LSP specification.
      --  When you add blink.cmp, luasnip, etc. Neovim now has *more* capabilities.
      --  So, we create new capabilities with blink.cmp, and then broadcast that to the servers.
      local capabilities = require('blink.cmp').get_lsp_capabilities()

      -- Enable the following language servers
      --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
      --
      --  Add any additional override configuration in the following tables. Available keys are:
      --  - cmd (table): Override the default command used to start the server
      --  - filetypes (table): Override the default list of associated filetypes for the server
      --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
      --  - settings (table): Override the default settings passed when initializing the server.
      --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
      local servers = opts.servers or {}

      -- Ensure the servers and tools above are installed
      --
      -- To check the current status of installed tools and/or manually install
      -- other tools, you can run
      --    :Mason
      --
      -- You can press `g?` for help in this menu.
      --
      -- `mason` had to be setup earlier: to configure its options see the
      -- `dependencies` table for `nvim-lspconfig` above.
      --
      -- You can add other tools here that you want Mason to install
      -- for you, so that they are available from within Neovim.
      local ensure_installed = vim.tbl_keys(servers or {})
      ensure_installed = vim.list_extend(ensure_installed, opts.ensure_installed or {})
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      local servers_no_install = opts.servers_no_install or {}
      servers = vim.tbl_extend('force', servers, servers_no_install)
      for server_name, _ in pairs(servers_no_install) do
        vim.lsp.enable(server_name)
      end

      require('mason-lspconfig').setup {
        ensure_installed = {}, -- explicitly set to an empty table (Kickstart populates installs via mason-tool-installer)
        diagnostics = opts.diagnostics or {},
        automatic_installation = false,
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            -- This handles overriding only values explicitly passed
            -- by the server configuration above. Useful when disabling
            -- certain features of an LSP (for example, turning off formatting for ts_ls)
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})

            -- Handle special setup functions
            if opts.setup and opts.setup[server] then
              if opts.setup[server](server) then
                goto continue
              end
            end

            vim.lsp.config(server_name, server)
            ::continue::
          end,
        },
      }
    end,
  },

  {
    'saghen/blink.cmp',
    dependencies = {
      'rafamadriz/friendly-snippets',
      'onsails/lspkind.nvim',
      'nvim-tree/nvim-web-devicons',
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
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
      },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
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
        '<cmd>FormatToggle!<cr>',
        mode = { 'n' },
        desc = 'Enable/Disable Format on Save for Buffer',
      },
      {
        '<leader>uf',
        '<cmd>FormatToggle<cr>',
        mode = { 'n' },
        desc = 'Enable/Disable Format on Save Globally',
      },
    },
    opts = {
      default_format_opts = {
        timeout_ms = 3000,
        async = false,
        quiet = false,
        lsp_format = 'fallback',
      },
      format_on_save = function(bufnr)
        -- Disable with a global or buffer-local variable
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        return { timeout_ms = 500, lsp_format = 'fallback' }
      end,
      -- ==========================================================================
      -- FORMATTERS BY FILETYPE (all in one place)
      -- ==========================================================================
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
            local ft = vim.bo[ctx.buf].filetype
            -- Default filetypes are always supported
            local supported = {
              'css', 'graphql', 'handlebars', 'html', 'javascript', 'javascriptreact',
              'json', 'jsonc', 'less', 'markdown', 'markdown.mdx', 'scss',
              'typescript', 'typescriptreact', 'vue', 'yaml',
            }
            if vim.tbl_contains(supported, ft) then
              return true
            end
            -- Otherwise check if a parser can be inferred
            local ret = vim.fn.system { 'prettier', '--file-info', ctx.filename }
            local ok, parser = pcall(function()
              return vim.fn.json_decode(ret).inferredParser
            end)
            return ok and parser and parser ~= vim.NIL
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
    config = function(_, opts)
      require('conform').setup(opts)
      vim.g.disable_autoformat = false
      vim.api.nvim_create_user_command('FormatToggle', function(args)
        local is_buf_disabled = function()
          return vim.b.disable_autoformat
        end
        local is_global_disabled = function()
          return vim.g.disable_autoformat
        end
        local toggle_global = function()
          vim.g.disable_autoformat = not is_global_disabled()
          if is_global_disabled() then
            vim.notify('Format on Save Disabled Globally', vim.log.levels.WARN)
          else
            vim.notify('Format on Save Enabled Globally', vim.log.levels.INFO)
          end
        end
        local toggle_buf = function()
          vim.b.disable_autoformat = not is_buf_disabled()
          if is_buf_disabled() then
            vim.notify('Format on Save Disabled for Buffer', vim.log.levels.WARN)
          else
            vim.notify('Format on Save Enabled for Buffer', vim.log.levels.INFO)
          end
        end

        if args.bang then
          -- FormatDisable! will disable formatting just for this buffer
          toggle_buf()
        else
          toggle_global()
        end
      end, {
        desc = 'Toggle autoformat-on-save',
        bang = true,
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
        cmake = { 'cmakelint' },
        dockerfile = { 'hadolint' },
        markdown = { 'markdownlint-cli2' },
        nu = { 'nu' },
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
    keys = function()
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

      -- stylua: ignore
      return {
        { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = "Breakpoint Condition" },
        { "<leader>db", function() require("dap").toggle_breakpoint() end,                                    desc = "Toggle Breakpoint" },
        { "<leader>dc", function() require("dap").continue() end,                                             desc = "Run/Continue" },
        { "<leader>da", function() require("dap").continue({ before = get_args }) end,                        desc = "Run with Args" },
        { "<leader>dC", function() require("dap").run_to_cursor() end,                                        desc = "Run to Cursor" },
        { "<leader>dg", function() require("dap").goto_() end,                                                desc = "Go to Line (No Execute)" },
        { "<leader>di", function() require("dap").step_into() end,                                            desc = "Step Into" },
        { "<leader>dj", function() require("dap").down() end,                                                 desc = "Down" },
        { "<leader>dk", function() require("dap").up() end,                                                   desc = "Up" },
        { "<leader>dl", function() require("dap").run_last() end,                                             desc = "Run Last" },
        { "<leader>do", function() require("dap").step_out() end,                                             desc = "Step Out" },
        { "<leader>dO", function() require("dap").step_over() end,                                            desc = "Step Over" },
        { "<leader>dP", function() require("dap").pause() end,                                                desc = "Pause" },
        { "<leader>dr", function() require("dap").repl.toggle() end,                                          desc = "Toggle REPL" },
        { "<leader>ds", function() require("dap").session() end,                                              desc = "Session" },
        { "<leader>dt", function() require("dap").terminate() end,                                            desc = "Terminate" },
        { "<leader>dw", function() require("dap.ui.widgets").hover() end,                                     desc = "Widgets" },
      }
    end,
    config = function()
      -- load mason-nvim-dap here, after all adapters have been setup
      require('mason-nvim-dap').setup(NvimLuaUtils.mason_nvim_dap_opts)

      vim.api.nvim_set_hl(0, 'DapStoppedLine', { default = true, link = 'Visual' })

      for name, sign in pairs(icons.dap) do
        sign = type(sign) == 'table' and sign or { sign }
        vim.fn.sign_define('Dap' .. name, { text = sign[1], texthl = sign[2] or 'DiagnosticInfo', linehl = sign[3] or '', numhl = sign[3] or '' })
      end

      -- setup dap config by VsCode launch.json file
      local vscode = require 'dap.ext.vscode'
      local json = require 'plenary.json'
      vscode.json_decode = function(str)
        return vim.json.decode(json.json_strip_comments(str))
      end

      local dap = require 'dap'
      local dapui = require 'dapui'

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

      -- Track disassembly buffers
      local disasm_buffers = {}

      -- Function to check if a buffer is a disassembly buffer
      local function is_disasm_buffer(bufnr)
        if not vim.api.nvim_buf_is_valid(bufnr) then
          return false
        end

        local bufname = vim.api.nvim_buf_get_name(bufnr)
        local filetype = vim.bo[bufnr].filetype
        local buftype = vim.bo[bufnr].buftype

        -- Check for DAP disassembly buffers: nofile type with empty name/filetype
        if buftype == 'nofile' and bufname == '' and filetype == '' then
          -- Additional check: look at buffer content to confirm it's disassembly
          local lines = vim.api.nvim_buf_get_lines(bufnr, 0, 10, false)
          for _, line in ipairs(lines) do
            -- Look for assembly-like patterns in the content
            if
              line:match '%s*0x%x+:' -- Address patterns like "0x1234:"
              or line:match '%s*%x+:%s+' -- Hex address with colon
              or line:match '%s+[a-z]+%s+' -- Assembly instructions
              or line:match 'mov%s+' -- Common assembly instructions
              or line:match 'push%s+'
              or line:match 'pop%s+'
              or line:match 'call%s+'
              or line:match 'ret%s*$'
            then
              return true
            end
          end
        end

        -- Also check for named disassembly buffers (just in case)
        return bufname:match 'dap://' or bufname:match 'disassembly' or filetype == 'asm' or filetype == 'disassembly'
      end

      -- Function to close all but the most recent disassembly buffer
      local function cleanup_old_disasm_buffers()
        -- Remove invalid buffers from tracking
        disasm_buffers = vim.tbl_filter(function(buf)
          return vim.api.nvim_buf_is_valid(buf)
        end, disasm_buffers)

        -- If we have more than one, close all but the last one
        while #disasm_buffers > 1 do
          local old_buf = table.remove(disasm_buffers, 1)
          if vim.api.nvim_buf_is_valid(old_buf) then
            vim.api.nvim_buf_delete(old_buf, { force = true })
          end
        end
      end

      -- Monitor all buffer events
      vim.api.nvim_create_autocmd({ 'BufNew', 'BufAdd', 'BufReadPost', 'FileType' }, {
        group = vim.api.nvim_create_augroup('dap-disasm-monitor', { clear = true }),
        callback = function(args)
          -- Use a timer to delay the check, allowing buffer content to load
          vim.defer_fn(function()
            if vim.api.nvim_buf_is_valid(args.buf) and is_disasm_buffer(args.buf) then
              -- Add to tracking list
              table.insert(disasm_buffers, args.buf)

              -- Clean up old ones
              cleanup_old_disasm_buffers()

              -- Add buffer-local keymap to close
              vim.keymap.set('n', 'q', function()
                vim.api.nvim_buf_delete(args.buf, { force = true })
                -- Remove from tracking
                disasm_buffers = vim.tbl_filter(function(buf)
                  return buf ~= args.buf
                end, disasm_buffers)
              end, { buffer = args.buf, desc = 'Close disassembly buffer' })

              -- Optional: Set a more descriptive name for the buffer
              vim.api.nvim_buf_set_name(args.buf, 'Disassembly-' .. args.buf)
            end
          end, 100) -- 100ms delay to allow content to load
        end,
      })
      -- Clean up all disasm buffers when debug session ends
      local function cleanup_all_disasm()
        for _, buf in ipairs(disasm_buffers) do
          if vim.api.nvim_buf_is_valid(buf) then
            vim.api.nvim_buf_delete(buf, { force = true })
          end
        end
        disasm_buffers = {}
      end

      dap.listeners.before.event_terminated['disasm_cleanup'] = cleanup_all_disasm
      dap.listeners.before.event_exited['disasm_cleanup'] = cleanup_all_disasm
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

  -- fancy UI for the debugger
  {
    'rcarriga/nvim-dap-ui',
    dependencies = { 'nvim-neotest/nvim-nio' },
    -- stylua: ignore
    keys = {
      { "<leader>du", function() require("dapui").toggle({}) end, desc = "Dap UI" },
      { "<leader>de", function() require("dapui").eval() end,     desc = "Eval",  mode = { "n", "v" } },
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
    opts = {},
    -- mason-nvim-dap is loaded when nvim-dap loads
    config = function(_, opts)
      NvimLuaUtils.mason_nvim_dap_opts = opts
    end,
  },

  -- Code refactoring tools
  {
    'ThePrimeagen/refactoring.nvim',
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
}
