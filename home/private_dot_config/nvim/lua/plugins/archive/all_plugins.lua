if true then
  return {}
end

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

---@class FzfLuaOpts: lazyvim.util.pick.Opts
---@field cmd string?

---@type LazyPicker
local picker = {
  name = 'fzf',
  commands = {
    files = 'files',
  },

  ---@param command string
  ---@param opts? FzfLuaOpts
  open = function(command, opts)
    opts = opts or {}
    if opts.cmd == nil and command == 'git_files' and opts.show_untracked then
      opts.cmd = 'git ls-files --exclude-standard --cached --others'
    end
    return require('fzf-lua')[command](opts)
  end,
}

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

---
---@alias ConformCtx {buf: number, filename: string, dirname: string}
local M = {}

local supported = {
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

--- Checks if a Prettier config file exists for the given context
---@param ctx ConformCtx
function M.has_config(ctx)
  vim.fn.system { 'prettier', '--find-config-path', ctx.filename }
  return vim.v.shell_error == 0
end

--- Checks if a parser can be inferred for the given context:
--- * If the filetype is in the supported list, return true
--- * Otherwise, check if a parser can be inferred
---@param ctx ConformCtx
function M.has_prettier_parser(ctx)
  local ft = vim.bo[ctx.buf].filetype --[[@as string]]
  -- default filetypes are always supported
  if vim.tbl_contains(supported, ft) then
    return true
  end
  -- otherwise, check if a parser can be inferred
  local ret = vim.fn.system { 'prettier', '--file-info', ctx.filename }
  ---@type boolean, string?
  local ok, parser = pcall(function()
    return vim.fn.json_decode(ret).inferredParser
  end)
  return ok and parser and parser ~= vim.NIL
end

return {
  'nvim-lua/plenary.nvim',
  {
    'nvchad/ui',
    config = function()
      require 'nvchad'
    end,
  },
  {
    'nvchad/base46',
    lazy = false,
    config = function()
      require('base46').load_all_highlights()
    end,
  },
  'nvchad/volt',
  {
    'saghen/blink.cmp',
    -- optional: provides snippets for the snippet source
    dependencies = {
      'rafamadriz/friendly-snippets',
      'onsails/lspkind.nvim',
      'nvim-tree/nvim-web-devicons',
    },

    -- use a release tag to download pre-built binaries
    version = '1.*',
    -- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
    -- build = 'cargo build --release',
    -- If you use nix, you can build from source using latest nightly rust with:
    -- build = 'nix run .#build-plugin',

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
      -- 'super-tab' for mappings similar to vscode (tab to accept)
      -- 'enter' for enter to accept
      -- 'none' for no mappings
      --
      -- All presets have the following mappings:
      -- C-space: Open menu or open docs if already open
      -- C-n/C-p or Up/Down: Select next/previous item
      -- C-e: Hide menu
      -- C-k: Toggle signature help (if signature.enabled = true)
      --
      -- See :h blink-cmp-config-keymap for defining your own keymap
      keymap = { preset = 'enter' },

      appearance = {
        -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        -- Adjusts spacing to ensure icons are aligned
        nerd_font_variant = 'mono',
      },

      -- (Default) Only show the documentation popup when manually triggered
      completion = {
        documentation = { auto_show = false },
      },

      -- Default list of enabled providers defined so that you can extend it
      -- elsewhere in your config, without redefining it, due to `opts_extend`
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
      },

      -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
      -- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
      -- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
      --
      -- See the fuzzy documentation for more information
      fuzzy = { implementation = 'prefer_rust_with_warning' },
    },
    opts_extend = {
      'sources.default',
      'sources.providers',
    },
  },
  { 'folke/lazy.nvim', version = '*' },
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
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    opts = {},
  },
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
        'diff',
        'html',
        'javascript',
        'jsdoc',
        'json',
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
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
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
  {
    'echasnovski/mini.pairs',
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
  {
    'folke/ts-comments.nvim',
    event = 'VeryLazy',
    opts = {},
  },
  {
    'echasnovski/mini.ai',
    -- opts = function()
    --   local ai = require 'mini.ai'
    --   return {
    --     n_lines = 500,
    --     custom_textobjects = {
    --       o = ai.gen_spec.treesitter { -- code block
    --         a = { '@block.outer', '@conditional.outer', '@loop.outer' },
    --         i = { '@block.inner', '@conditional.inner', '@loop.inner' },
    --       },
    --       f = ai.gen_spec.treesitter { a = '@function.outer', i = '@function.inner' }, -- function
    --       c = ai.gen_spec.treesitter { a = '@class.outer', i = '@class.inner' }, -- class
    --       t = { '<([%p%w]-)%f[^<%w][^<>]->.-</%1>', '^<.->().*()</[^/]->$' }, -- tags
    --       d = { '%f[%d]%d+' }, -- digits
    --       e = { -- Word with case
    --         { '%u[%l%d]+%f[^%l%d]', '%f[%S][%l%d]+%f[^%l%d]', '%f[%P][%l%d]+%f[^%l%d]', '^[%l%d]+%f[^%l%d]' },
    --         '^().*()$',
    --       },
    --       g = LazyVim.mini.ai_buffer, -- buffer
    --       u = ai.gen_spec.function_call(), -- u for "Usage"
    --       U = ai.gen_spec.function_call { name_pattern = '[%w_]' }, -- without dot in function name
    --     },
    --   }
    -- end,
  },
  {
    'MagicDuck/grug-far.nvim',
    opts = { headerMaxWidth = 80 },
    cmd = 'GrugFar',
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
  {
    'folke/flash.nvim',
    event = 'VeryLazy',
    ---@type Flash.Config
    opts = {},
    -- stylua: ignore
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
  },
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
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '▎' },
        change = { text = '▎' },
        delete = { text = '' },
        topdelete = { text = '' },
        changedelete = { text = '▎' },
        untracked = { text = '▎' },
      },
      signs_staged = {
        add = { text = '▎' },
        change = { text = '▎' },
        delete = { text = '' },
        topdelete = { text = '' },
        changedelete = { text = '▎' },
      },
      on_attach = function(buffer)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
        end

      -- stylua: ignore start
      map("n", "]h", function()
        if vim.wo.diff then
          vim.cmd.normal({ "]c", bang = true })
        else
          gs.nav_hunk("next")
        end
      end, "Next Hunk")
      map("n", "[h", function()
        if vim.wo.diff then
          vim.cmd.normal({ "[c", bang = true })
        else
          gs.nav_hunk("prev")
        end
      end, "Prev Hunk")
      map("n", "]H", function() gs.nav_hunk("last") end, "Last Hunk")
      map("n", "[H", function() gs.nav_hunk("first") end, "First Hunk")
      map({ "n", "v" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
      map({ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
      map("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
      map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
      map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
      map("n", "<leader>ghp", gs.preview_hunk_inline, "Preview Hunk Inline")
      map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame Line")
      map("n", "<leader>ghB", function() gs.blame() end, "Blame Buffer")
      map("n", "<leader>ghd", gs.diffthis, "Diff This")
      map("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff This ~")
      map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
      end,
    },
  },
  {
    'gitsigns.nvim',
    opts = function()
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
  {
    'folke/todo-comments.nvim',
    cmd = { 'TodoTrouble', 'TodoTelescope' },
    opts = {},
    -- stylua: ignore
    keys = {
      { "]t", function() require("todo-comments").jump_next() end, desc = "Next Todo Comment" },
      { "[t", function() require("todo-comments").jump_prev() end, desc = "Previous Todo Comment" },
      { "<leader>xt", "<cmd>Trouble todo toggle<cr>", desc = "Todo (Trouble)" },
      { "<leader>xT", "<cmd>Trouble todo toggle filter = {tag = {TODO,FIX,FIXME}}<cr>", desc = "Todo/Fix/Fixme (Trouble)" },
      { "<leader>st", "<cmd>TodoTelescope<cr>", desc = "Todo" },
      { "<leader>sT", "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>", desc = "Todo/Fix/Fixme" },
    },
  },
  {
    'stevearc/conform.nvim',
    dependencies = {
      'mason.nvim',
      opts = {
        ensure_installed = {
          'stylua', -- lua formatter
        },
      },
    },
    lazy = false,
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
      ---@type conform.setupOpts
      local opts = {
        default_format_opts = {
          timeout_ms = 3000,
          async = false, -- not recommended to change
          quiet = false, -- not recommended to change
          lsp_format = 'fallback', -- not recommended to change
        },
        formatters_by_ft = {
          lua = { 'stylua' },
          -- fish = { 'fish_indent' },
          -- sh = { 'shfmt' },
        },
        -- The options you set here will be merged with the builtin formatters.
        -- You can also define any custom formatters here.
        ---@type table<string, conform.FormatterConfigOverride|fun(bufnr: integer): nil|conform.FormatterConfigOverride>
        formatters = {
          injected = { options = { ignore_errors = true } },
          -- # Example of using dprint only when a dprint.json file is present
          -- dprint = {
          --   condition = function(ctx)
          --     return vim.fs.find({ "dprint.json" }, { path = ctx.filename, upward = true })[1]
          --   end,
          -- },
          --
          -- # Example of using shfmt with extra args
          -- shfmt = {
          --   prepend_args = { "-i", "2", "-ci" },
          -- },
        },
      }
      return opts
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
  {
    'mfussenegger/nvim-lint',
    opts = {
      -- Event to trigger linters
      events = { 'BufWritePost', 'BufReadPost', 'InsertLeave' },
      linters_by_ft = {
        fish = { 'fish' },
        -- Use the "*" filetype to run linters on all filetypes.
        -- ['*'] = { 'global linter' },
        -- Use the "_" filetype to run linters on filetypes that don't have other linters configured.
        -- ['_'] = { 'fallback linter' },
        -- ["*"] = { "typos" },
      },
      -- LazyVim extension to easily override linter options
      -- or add custom linters.
      ---@type table<string,table>
      linters = {
        -- -- Example of using selene only when a selene.toml file is present
        -- selene = {
        --   -- `condition` is another LazyVim extension that allows you to
        --   -- dynamically enable/disable linters based on the context.
        --   condition = function(ctx)
        --     return vim.fs.find({ "selene.toml" }, { path = ctx.filename, upward = true })[1]
        --   end,
        -- },
      },
    },
    config = function(_, opts)
      local M = {}

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

      function M.debounce(ms, fn)
        local timer = vim.uv.new_timer()
        return function(...)
          local argv = { ... }
          timer:start(ms, 0, function()
            timer:stop()
            vim.schedule_wrap(fn)(unpack(argv))
          end)
        end
      end

      function M.lint()
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
          -- if not linter then
          --   LazyVim.warn('Linter not found: ' .. name, { title = 'nvim-lint' })
          -- end
          return linter and not (type(linter) == 'table' and linter.condition and not linter.condition(ctx))
        end, names)

        -- Run linters.
        if #names > 0 then
          lint.try_lint(names)
        end
      end

      vim.api.nvim_create_autocmd(opts.events, {
        group = vim.api.nvim_create_augroup('nvim-lint', { clear = true }),
        callback = M.debounce(100, M.lint),
      })
    end,
  },
  {
    'folke/which-key.nvim',
    opts = {
      spec = {
        { '<BS>', desc = 'Decrement Selection', mode = 'x' },
        { '<c-space>', desc = 'Increment Selection', mode = { 'x', 'n' } },
      },
    },
  },
  {
    'windwp/nvim-ts-autotag',
    opts = {},
  },
  { 'tiagovla/scope.nvim', config = true },
  {
    'romgrk/barbar.nvim',
    lazy = false,
    enabled = false,
    dependencies = {
      'lewis6991/gitsigns.nvim', -- OPTIONAL: for git status
      'nvim-tree/nvim-web-devicons', -- OPTIONAL: for file icons
    },
    keys = {
      { '<leader>bs', '<Cmd>BufferPick<CR>', desc = 'Select Buffer' },
      { '<leader>bS', '<Cmd>BufferPickDelete<CR>', desc = 'Select Buffer to Delete' },
      { '<leader>bc', '<Cmd>BufferClose<CR>', desc = 'Close Buffer' },
      { '<leader>bR', '<Cmd>BufferRestore<CR>', desc = 'Restore Buffer' },
      { '<leader>bp', '<Cmd>BufferPin<CR>', desc = 'Toggle Pin' },
      { '<leader>bP', '<Cmd>BufferCloseAllButPinned<CR>', desc = 'Delete Non-Pinned Buffers' },
      { '<leader>br', '<Cmd>BufferCloseBuffersRight<CR>', desc = 'Delete Buffers to the Right' },
      { '<leader>bl', '<Cmd>BufferCloseBuffersLeft<CR>', desc = 'Delete Buffers to the Left' },
      { '<S-h>', '<cmd>BufferPrevious<cr>', desc = 'Prev Buffer' },
      { '<S-l>', '<cmd>BufferNext<cr>', desc = 'Next Buffer' },
      -- { "[b", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
      -- { "]b", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
      { '[B', '<cmd>BufferMovePrev<cr>', desc = 'Move buffer prev' },
      { ']B', '<cmd>BufferMoveNext<cr>', desc = 'Move buffer next' },
    },
    init = function()
      vim.g.barbar_auto_setup = false
    end,
    opts = {
      -- lazy.nvim will automatically call setup for you. put your options here, anything missing will use the default:
      -- animation = true,
      -- insert_at_start = true,
      -- …etc.
    },
    version = '^1.0.0', -- optional: only update when a new 1.x version is released
  },
  {
    'akinsho/bufferline.nvim',
    enabled = true,
    event = 'BufEnter',
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
        -- stylua: ignore
        close_command = function(n) Snacks.bufdelete(n) end,
        -- stylua: ignore
        right_mouse_command = function(n) Snacks.bufdelete(n) end,
        diagnostics = 'nvim_lsp',
        always_show_bufferline = true,
        -- diagnostics_indicator = function(_, _, diag)
        --   local icons = LazyVim.config.icons.diagnostics
        --   local ret = (diag.error and icons.Error .. diag.error .. " " or "")
        --     .. (diag.warning and icons.Warn .. diag.warning or "")
        --   return vim.trim(ret)
        -- end,
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
        ---@param opts bufferline.IconFetcherOpts
        -- get_element_icon = function(opts)
        --   return LazyVim.config.icons.ft[opts.filetype]
        -- end,
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
  -- stylua: ignore
  keys = {
    { "<leader>sn", "", desc = "+noice"},
    { "<S-Enter>", function() require("noice").redirect(vim.fn.getcmdline()) end, mode = "c", desc = "Redirect Cmdline" },
    { "<leader>snl", function() require("noice").cmd("last") end, desc = "Noice Last Message" },
    { "<leader>snh", function() require("noice").cmd("history") end, desc = "Noice History" },
    { "<leader>sna", function() require("noice").cmd("all") end, desc = "Noice All" },
    { "<leader>snd", function() require("noice").cmd("dismiss") end, desc = "Dismiss All" },
    { "<leader>snt", function() require("noice").cmd("pick") end, desc = "Noice Picker (Telescope/FzfLua)" },
    { "<c-f>", function() if not require("noice.lsp").scroll(4) then return "<c-f>" end end, silent = true, expr = true, desc = "Scroll Forward", mode = {"i", "n", "s"} },
    { "<c-b>", function() if not require("noice.lsp").scroll(-4) then return "<c-b>" end end, silent = true, expr = true, desc = "Scroll Backward", mode = {"i", "n", "s"}},
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
  { 'MunifTanjim/nui.nvim', lazy = true },
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
    },
    -- stylua: ignore
    keys = {
      { "<leader>n", function()
        if Snacks.config.picker and Snacks.config.picker.enabled then
          Snacks.picker.notifications()
        else
          Snacks.notifier.show_history()
        end
      end, desc = "Notification History" },
      { "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },
    },
  },
  {
    desc = 'Snacks File Explorer',
    recommended = true,
    'folke/snacks.nvim',
    opts = { explorer = {} },
    keys = {
      -- {
      --   '<leader>fe',
      --   function()
      --     Snacks.explorer { cwd = LazyVim.root() }
      --   end,
      --   desc = 'Explorer Snacks (root dir)',
      -- },
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
  {
    'snacks.nvim',
    opts = {
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
        -- stylua: ignore
        ---@type snacks.dashboard.Item[]
        keys = {
          { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
          { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
          { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
          { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
          { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
          { icon = " ", key = "s", desc = "Restore Session", section = "session" },
          { icon = " ", key = "x", desc = "Lazy Extras", action = ":LazyExtras" },
          { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
        },
      },
    },
  },
  {
    'snacks.nvim',
    opts = {
      bigfile = { enabled = true },
      quickfile = { enabled = true },
      terminal = {
        -- win = {
        --   keys = {
        --     nav_h = { '<C-h>', term_nav 'h', desc = 'Go to Left Window', expr = true, mode = 't' },
        --     nav_j = { '<C-j>', term_nav 'j', desc = 'Go to Lower Window', expr = true, mode = 't' },
        --     nav_k = { '<C-k>', term_nav 'k', desc = 'Go to Upper Window', expr = true, mode = 't' },
        --     nav_l = { '<C-l>', term_nav 'l', desc = 'Go to Right Window', expr = true, mode = 't' },
        --   },
        -- },
      },
    },
    -- stylua: ignore
    keys = {
      { "<leader>.",  function() Snacks.scratch() end, desc = "Toggle Scratch Buffer" },
      { "<leader>S",  function() Snacks.scratch.select() end, desc = "Select Scratch Buffer" },
      { "<leader>dps", function() Snacks.profiler.scratch() end, desc = "Profiler Scratch Buffer" },
    },
  },
  {
    'folke/persistence.nvim',
    event = 'BufReadPre',
    opts = {},
    -- stylua: ignore
    keys = {
      { "<leader>qs", function() require("persistence").load() end, desc = "Restore Session" },
      { "<leader>qS", function() require("persistence").select() end,desc = "Select Session" },
      { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session" },
      { "<leader>qd", function() require("persistence").stop() end, desc = "Don't Save Current Session" },
    },
  },
  { 'nvim-lua/plenary.nvim', lazy = true },
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'blink.cmp',
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
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
          -- Add more server configurations here
          -- tsserver = {},
          -- pyright = {},
        },
        servers_no_install = {},
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
        lspconfig[server].setup(config)
      end
    end,
  },
  {
    'mason.nvim',
    { 'mason-org/mason-lspconfig.nvim', config = function() end },
  },
  { 'mason-org/mason-lspconfig.nvim', config = function() end },
  {

    'mason-org/mason.nvim',
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
        'stylua',
        'shfmt',
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
  {
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    event = 'InsertEnter',
    opts = {
      suggestion = { enabled = false },
      panel = { enabled = false },
    },
  },
  {
    'saghen/blink.cmp',
    optional = true,
    dependencies = { 'fang2hou/blink-copilot' },
    opts = {
      sources = {
        default = { 'copilot' },
        providers = {
          copilot = {
            name = 'copilot',
            module = 'blink-copilot',
            score_offset = 100,
            async = true,
            opts = {
              max_completions = 3,
              max_attempts = 4,
              kind_name = 'Copilot', ---@type string | false
              kind_icon = ' ', ---@type string | false
              kind_hl = false, ---@type string | false
              debounce = 200, ---@type integer | false
              auto_refresh = {
                backward = true,
                forward = true,
              },
            },
          },
        },
      },
    },
  },
  {
    'mason-org/mason.nvim',
    opts = { ensure_installed = { 'prettier', 'black' } },
  },

  -- conform
  {
    'stevearc/conform.nvim',
    optional = true,
    ---@param opts ConformOpts
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      for _, ft in ipairs(supported) do
        opts.formatters_by_ft[ft] = opts.formatters_by_ft[ft] or {}
        table.insert(opts.formatters_by_ft[ft], 'prettier')
      end

      opts.formatters = opts.formatters or {}
      opts.formatters.prettier = {
        condition = function(_, ctx)
          return M.has_prettier_parser(ctx)
        end,
      }
    end,
  },
  {
    'stevearc/conform.nvim',
    optional = true,
    opts = {
      formatters_by_ft = {
        ['python'] = { 'black' },
      },
    },
  },

  {
    'ibhagwan/fzf-lua',
    dependencies = {
      'trouble.nvim',
    },
    cmd = 'FzfLua',
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

      -- Trouble
      config.defaults.actions.files['ctrl-t'] = require('trouble.sources.fzf').actions.open

      -- Toggle root dir / cwd
      -- config.defaults.actions.files['ctrl-r'] = function(_, ctx)
      --   local o = vim.deepcopy(ctx.__call_opts)
      --   o.root = o.root == false
      --   o.cwd = nil
      --   o.buf = ctx.__CTX.bufnr
      --   LazyVim.pick.open(ctx.__INFO.cmd, o)
      -- end
      config.defaults.actions.files['alt-c'] = config.defaults.actions.files['ctrl-r']
      -- config.set_action_helpstr(config.defaults.actions.files['ctrl-r'], 'toggle-root-dir')

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
          -- formatter = "path.filename_first",
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
            prompt = ' ',
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
              -- preview = not vim.tbl_isempty(LazyVim.lsp.get_clients { bufnr = 0, name = 'vtsls' }) and {
              --   layout = 'vertical',
              --   vertical = 'down:15,border-top',
              --   hidden = 'hidden',
              -- } or {
              --   layout = 'vertical',
              --   vertical = 'down:15,border-top',
              -- },
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
              return s:lower() .. '\t'
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
          t.prompt = t.prompt ~= nil and ' ' or nil
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
      {
        '<leader>,',
        '<cmd>FzfLua buffers sort_mru=true sort_lastused=true<cr>',
        desc = 'Switch Buffer',
      },
      -- { '<leader>/', LazyVim.pick 'live_grep', desc = 'Grep (Root Dir)' },
      { '<leader>:', '<cmd>FzfLua command_history<cr>', desc = 'Command History' },
      -- { '<leader><space>', LazyVim.pick 'files', desc = 'Find Files (Root Dir)' },
      -- find
      { '<leader>fb', '<cmd>FzfLua buffers sort_mru=true sort_lastused=true<cr>', desc = 'Buffers' },
      -- { '<leader>fc', LazyVim.pick.config_files(), desc = 'Find Config File' },
      -- { '<leader>ff', LazyVim.pick('files', { root = true }), desc = 'Find Files (Root Dir)' },
      { '<leader>ff', '<cmd>FzfLua files<cr>', desc = 'Find Files (cwd)' },
      { '<leader>fg', '<cmd>FzfLua git_files<cr>', desc = 'Find Files (git-files)' },
      { '<leader>fr', '<cmd>FzfLua oldfiles<cr>', desc = 'Recent' },
      -- { '<leader>fR', LazyVim.pick('oldfiles', { cwd = vim.uv.cwd() }), desc = 'Recent (cwd)' },
      -- git
      { '<leader>gc', '<cmd>FzfLua git_commits<CR>', desc = 'Commits' },
      { '<leader>gs', '<cmd>FzfLua git_status<CR>', desc = 'Status' },
      -- search
      { '<leader>s"', '<cmd>FzfLua registers<cr>', desc = 'Registers' },
      { '<leader>sa', '<cmd>FzfLua autocmds<cr>', desc = 'Auto Commands' },
      { '<leader>sb', '<cmd>FzfLua grep_curbuf<cr>', desc = 'Buffer' },
      { '<leader>sc', '<cmd>FzfLua command_history<cr>', desc = 'Command History' },
      { '<leader>sC', '<cmd>FzfLua commands<cr>', desc = 'Commands' },
      { '<leader>sd', '<cmd>FzfLua diagnostics_document<cr>', desc = 'Document Diagnostics' },
      { '<leader>sD', '<cmd>FzfLua diagnostics_workspace<cr>', desc = 'Workspace Diagnostics' },
      { '<leader>sg', '<cmd>FzfLua live_grep<cr>', desc = 'Grep (cwd)' },
      -- { '<leader>sG', LazyVim.pick('live_grep', { root = true }), desc = 'Grep (Root dir)' },
      { '<leader>sh', '<cmd>FzfLua help_tags<cr>', desc = 'Help Pages' },
      { '<leader>sH', '<cmd>FzfLua highlights<cr>', desc = 'Search Highlight Groups' },
      { '<leader>sj', '<cmd>FzfLua jumps<cr>', desc = 'Jumplist' },
      { '<leader>sk', '<cmd>FzfLua keymaps<cr>', desc = 'Key Maps' },
      { '<leader>sl', '<cmd>FzfLua loclist<cr>', desc = 'Location List' },
      { '<leader>sM', '<cmd>FzfLua man_pages<cr>', desc = 'Man Pages' },
      { '<leader>sm', '<cmd>FzfLua marks<cr>', desc = 'Jump to Mark' },
      { '<leader>sR', '<cmd>FzfLua resume<cr>', desc = 'Resume' },
      { '<leader>sq', '<cmd>FzfLua quickfix<cr>', desc = 'Quickfix List' },
      -- { '<leader>sw', LazyVim.pick 'grep_cword', desc = 'Word (Root Dir)' },
      { '<leader>sW', '<cmd>FzfLua grep_cword<cr>', desc = 'Word (cwd)' },
      -- { '<leader>sw', LazyVim.pick 'grep_visual', mode = 'v', desc = 'Selection (Root Dir)' },
      { '<leader>sW', '<cmd>FzfLua grep_visual<cr>', mode = 'v', desc = 'Selection (cwd)' },
      -- { '<leader>uC', LazyVim.pick 'colorschemes', desc = 'Colorscheme with Preview' },
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

  {
    'folke/todo-comments.nvim',
    optional = true,
    -- stylua: ignore
    keys = {
      { "<leader>st", function() require("todo-comments.fzf").todo() end, desc = "Todo" },
      { "<leader>sT", function () require("todo-comments.fzf").todo({ keywords = { "TODO", "FIX", "FIXME" } }) end, desc = "Todo/Fix/Fixme" },
    },
  },

  {
    'neovim/nvim-lspconfig',
    opts = function()
      local keys = require('config.lsp_keymaps').get()
      -- stylua: ignore
      vim.list_extend(keys, {
        { "gd", "<cmd>FzfLua lsp_definitions     jump1=true ignore_current_line=true<cr>", desc = "Goto Definition", has = "definition" },
        { "gr", "<cmd>FzfLua lsp_references      jump1=true ignore_current_line=true<cr>", desc = "References", nowait = true },
        { "gI", "<cmd>FzfLua lsp_implementations jump1=true ignore_current_line=true<cr>", desc = "Goto Implementation" },
        { "gy", "<cmd>FzfLua lsp_typedefs        jump1=true ignore_current_line=true<cr>", desc = "Goto T[y]pe Definition" },
      })
    end,
  },
  -- disable snacks indent when indent-blankline is enabled
  {
    'snacks.nvim',
    opts = {
      indent = { enabled = false },
    },
  },
  {
    'lukas-reineke/indent-blankline.nvim',
    dependencies = {
      'snacks.nvim',
    },
    opts = function()
      Snacks.toggle({
        name = 'Indention Guides',
        get = function()
          return require('ibl.config').get_config(0).enabled
        end,
        set = function(state)
          require('ibl').setup_buffer(0, { enabled = state })
        end,
      }):map '<leader>ug'

      return {
        indent = {
          char = '│',
          tab_char = '│',
        },
        scope = { show_start = false, show_end = false },
        exclude = {
          filetypes = {
            'Trouble',
            'alpha',
            'dashboard',
            'help',
            'lazy',
            'mason',
            'neo-tree',
            'notify',
            'snacks_dashboard',
            'snacks_notif',
            'snacks_terminal',
            'snacks_win',
            'toggleterm',
            'trouble',
          },
        },
      }
    end,
    main = 'ibl',
  },

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
  -- disable builtin snippet support
  { 'garymjr/nvim-snippets', enabled = false },

  -- add luasnip
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

  -- blink.cmp integration
  {
    'saghen/blink.cmp',
    optional = true,
    opts = {
      snippets = {
        preset = 'luasnip',
      },
    },
  },
  {
    'echasnovski/mini.files',
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
  -- Fast and feature-rich surround actions. For text that includes
  -- surrounding characters like brackets or quotes, this allows you
  -- to select the text inside, change or modify the surrounding characters,
  -- and more.

  {
    'echasnovski/mini.surround',
    keys = function(_, keys)
      local opts = mini_surround_opts
      -- Populate the keys based on the user's options
      local mappings = {
        { opts.mappings.add, desc = 'Add Surrounding', mode = { 'n', 'v' } },
        { opts.mappings.delete, desc = 'Delete Surrounding' },
        { opts.mappings.find, desc = 'Find Right Surrounding' },
        { opts.mappings.find_left, desc = 'Find Left Surrounding' },
        { opts.mappings.highlight, desc = 'Highlight Surrounding' },
        { opts.mappings.replace, desc = 'Replace Surrounding' },
        { opts.mappings.update_n_lines, desc = 'Update `MiniSurround.config.n_lines`' },
      }
      mappings = vim.tbl_filter(function(m)
        return m[1] and #m[1] > 0
      end, mappings)
      return vim.list_extend(mappings, keys)
    end,
    opts = mini_surround_opts,
  },

  {
    'ThePrimeagen/refactoring.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
    keys = {
      { '<leader>r', '', desc = '+refactor', mode = { 'n', 'v' } },
      {
        '<leader>rs',
        pick,
        mode = 'v',
        desc = 'Refactor',
      },
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
    },
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
      -- i.e. [Refactor] Inlined 3 variable occurrences
    },
  },
  -- AI code completion engine
  {
    'zbirenbaum/copilot.lua',
    dependencies = { 'blink.cmp' },
    event = { 'InsertEnter' },
    cmd = { 'Copilot' },
    opts = {
      panel = { enabled = false },
      suggestion = { enabled = false },
      filetypes = {
        markdown = true,
        help = true,
      },
      lsp_binary = 'copilot-language-server',
    },
  },
  -- Debug Adapter Protocol implementation
  {
    'mfussenegger/nvim-dap',
    cmd = { 'DapToggleBreakpoint', 'DapContinue' },
    dependencies = {
      -- Add UI elements for DAP
      {
        'rcarriga/nvim-dap-ui',
        dependencies = { 'nvim-neotest/nvim-nio' },
        opts = {},
      },
      -- Virtual text for breakpoints, etc.
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

      -- Configure C/C++ debugger
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
            stopOnEntry = true,
          },
          {
            type = 'codelldb',
            request = 'attach',
            name = 'Attach to process',
            pid = require('dap.utils').pick_process,
            cwd = '${workspaceFolder}',
            stopOnEntry = true,
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
  {
    'nmac427/guess-indent.nvim',
    config = function()
      require('guess-indent').setup {}
    end,
  },

  -- Markdown Preview integration
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
  {
    'nvzone/showkeys',
    cmd = 'ShowkeysToggle',
    opts = {

      timeout = 3, -- in secs
      maxkeys = 10,
      show_count = true,
      excluded_modes = {}, -- example: {"i"}

      -- bottom-left, bottom-right, bottom-center, top-left, top-right, top-center
      position = 'top-center',
    },
  },
}
