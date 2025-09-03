local icons = {
  misc = {
    dots = '󰇘',
  },
  ft = {
    octo = '',
  },
  dap = {
    Stopped = { '󰁕 ', 'DiagnosticWarn', 'DapStoppedLine' },
    Breakpoint = ' ',
    BreakpointCondition = ' ',
    BreakpointRejected = { ' ', 'DiagnosticError' },
    LogPoint = '.>',
  },
  diagnostics = {
    Error = ' ',
    Warn = ' ',
    Hint = ' ',
    Info = ' ',
  },
  git = {
    added = ' ',
    modified = ' ',
    removed = ' ',
  },
  kinds = {
    Array = ' ',
    Boolean = '󰨙 ',
    Class = ' ',
    Codeium = '󰘦 ',
    Color = ' ',
    Control = ' ',
    Collapsed = ' ',
    Constant = '󰏿 ',
    Constructor = ' ',
    Copilot = ' ',
    Enum = ' ',
    EnumMember = ' ',
    Event = ' ',
    Field = ' ',
    File = ' ',
    Folder = ' ',
    Function = '󰊕 ',
    Interface = ' ',
    Key = ' ',
    Keyword = ' ',
    Method = '󰊕 ',
    Module = ' ',
    Namespace = '󰦮 ',
    Null = ' ',
    Number = '󰎠 ',
    Object = ' ',
    Operator = ' ',
    Package = ' ',
    Property = ' ',
    Reference = ' ',
    Snippet = '󱄽 ',
    String = ' ',
    Struct = '󰆼 ',
    Supermaven = ' ',
    TabNine = '󰏚 ',
    Text = ' ',
    TypeParameter = ' ',
    Unit = ' ',
    Value = ' ',
    Variable = '󰀫 ',
  },
}

return {
  -- ============================================================================
  -- LSP & COMPLETION
  -- ============================================================================
  {
    -- Main LSP Configuration
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim
      -- Mason must be loaded before its dependents so we need to set it up here.
      -- NOTE: `opts = {}` is the same as calling `require('mason').setup({})`
      {
        'mason-org/mason.nvim',
        cmd = 'Mason',
        keys = { { '<leader>cm', '<cmd>Mason<cr>', desc = 'Mason' } },
        opts = {},
      },
      'mason-org/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- Useful status updates for LSP.
      { 'j-hui/fidget.nvim', opts = {} },

      -- Allows extra capabilities provided by blink.cmp
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
      -- LSP server configurations
      servers_no_install = {},
      servers = {},
      setup = {},
      ensure_installed = {},
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
          -- NOTE: Remember that Lua is a real programming language, and as such it is possible
          -- to define small helper and utility functions so you don't have to repeat yourself.
          --

          local function kickstart_keymaps()
            -- In this case, we create a function that lets us more easily define mappings specific
            -- for LSP related items. It sets the mode, buffer and description for us each time.
            local map = function(keys, func, desc, mode)
              mode = mode or 'n'
              vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
            end

            -- Rename the variable under your cursor.
            --  Most Language Servers support renaming across files, etc.
            map('grn', vim.lsp.buf.rename, '[R]e[n]ame')

            -- Execute a code action, usually your cursor needs to be on top of an error
            -- or a suggestion from your LSP for this to activate.
            map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })

            -- Find references for the word under your cursor.
            map('grr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

            -- Jump to the implementation of the word under your cursor.
            --  Useful when your language has ways of declaring types without an actual implementation.
            map('gri', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')

            -- Jump to the definition of the word under your cursor.
            --  This is where a variable was first declared, or where a function is defined, etc.
            --  To jump back, press <C-t>.
            map('grd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

            -- WARN: This is not Goto Definition, this is Goto Declaration.
            --  For example, in C this would take you to the header.
            map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

            -- Fuzzy find all the symbols in your current document.
            --  Symbols are things like variables, functions, types, etc.
            map('gO', require('telescope.builtin').lsp_document_symbols, 'Open Document Symbols')

            -- Fuzzy find all the symbols in your current workspace.
            --  Similar to document symbols, except searches over your entire project.
            map('gW', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Open Workspace Symbols')

            -- Jump to the type of the word under your cursor.
            --  Useful when you're not sure what type a variable is and you want to see
            --  the definition of its *type*, not where it was *defined*.
            map('grt', require('telescope.builtin').lsp_type_definitions, '[G]oto [T]ype Definition')
          end

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

          -- -- The following code creates a keymap to toggle inlay hints in your
          -- -- code, if the language server you are using supports them
          -- --
          -- -- This may be unwanted, since they displace some of your code
          -- if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
          --   map('<leader>th', function()
          --     vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
          --   end, '[T]oggle Inlay [H]ints')
          -- end
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

            require('lspconfig')[server_name].setup(server)
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
        documentation = { auto_show = false },
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
      formatters_by_ft = {},
      formatters = { injected = { options = { ignore_errors = true } } },
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
      linters_by_ft = {},
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

      -- Ensure only one disassembly/instruction buffer is open at a time
      local function close_existing_disassembly_buffers()
        vim.api.nvim_create_autocmd('BufWinEnter', {
          group = vim.api.nvim_create_augroup('dap-disassembly-wipe', { clear = true }),
          callback = function(args)
            local new_buf = args.buf
            local new_name = vim.api.nvim_buf_get_name(new_buf)
            local patterns = {
              '^%[dap%-disassembly%]',
              '^%[dap%-instructions%]',
              '^Disassembly',
              '^Instructions',
            }
            local function is_disassembly(name)
              for _, pat in ipairs(patterns) do
                if name:match(pat) then
                  return true
                end
              end
              return false
            end
            if is_disassembly(new_name) then
              for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                if buf ~= new_buf and vim.api.nvim_buf_is_loaded(buf) then
                  local name = vim.api.nvim_buf_get_name(buf)
                  if is_disassembly(name) then
                    vim.api.nvim_buf_delete(buf, { force = true })
                  end
                end
              end
              -- Optionally, set bufhidden=wipe for the new buffer
              vim.api.nvim_buf_set_option(new_buf, 'bufhidden', 'wipe')
            end
          end,
        })
      end
      close_existing_disassembly_buffers()
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
}
