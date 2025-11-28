--[[
=====================================================================
                    Neovim Plugins - Editor Core
=====================================================================

This file configures core editor functionality plugins that enhance
the text editing experience, including syntax highlighting, motions,
text objects, and general editor improvements.

PLUGIN OVERVIEW:

  Syntax & Parsing:
    - nvim-treesitter         : Syntax highlighting, folding, indentation
    - nvim-treesitter-textobjects : Enhanced text objects based on syntax
    - nvim-treesitter-context : Shows current function/class at top of buffer

  Text Editing:
    - mini.pairs              : Auto-pair brackets, quotes, etc.
    - mini.ai                 : Enhanced text objects (around/inside)
    - ts-comments.nvim        : Smart commenting based on treesitter
    - nvim-ts-autotag         : Auto-close HTML/XML tags

  Navigation & Motion:
    - flash.nvim              : Fast navigation with labels
    - which-key.nvim          : Keybinding hints and discovery

  Utilities:
    - guess-indent.nvim       : Automatic indentation detection

TREESITTER PARSERS (ensure_installed):
  Languages: bash, c, cmake, cpp, css, diff, dockerfile, git_config,
             gitcommit, git_rebase, gitignore, gitattributes, html,
             javascript, jsdoc, json, json5, jsonc, lua, luadoc, luap,
             markdown, markdown_inline, nu, printf, python, query,
             regex, toml, tsx, typescript, vim, vimdoc, xml, yaml

KEY MAPPINGS:

  Treesitter:
    <C-space>  : Increment selection (expand selection by syntax node)
    <BS>       : Decrement selection (shrink selection)
    ]f / [f    : Next/previous function
    ]c / [c    : Next/previous class
    ]a / [a    : Next/previous parameter

  Flash (s/S motions):
    s          : Flash jump (type characters to jump)
    S          : Flash treesitter (select by syntax node)
    r          : Remote flash (operator-pending mode)
    R          : Treesitter search
    <C-s>      : Toggle flash search (in command mode)

  Which-key:
    <leader>?  : Show buffer keymaps
    <C-w><space> : Window hydra mode

  Treesitter Context:
    <leader>ut : Toggle treesitter context display

@see https://github.com/nvim-treesitter/nvim-treesitter
@see https://github.com/folke/flash.nvim
]]

return {
  -- ============================================================================
  -- SYNTAX & PARSING
  -- ============================================================================

  --[[
    nvim-treesitter - Advanced Syntax Highlighting
    
    Treesitter provides:
    - Better syntax highlighting based on AST parsing
    - Code folding based on syntax structure
    - Indentation based on language semantics
    - Incremental selection (expand/shrink by syntax node)
    - Foundation for many other plugins (textobjects, context, etc.)
  ]]
  {
    'nvim-treesitter/nvim-treesitter',
    version = false, -- last release is way too old and doesn't work on Windows
    lazy = false,    -- load treesitter early when opening a file from the cmdline
    cmd = { 'TSUpdateSync', 'TSUpdate', 'TSInstall' },
    keys = {
      { '<c-space>', desc = 'Increment Selection' },
      { '<bs>',      desc = 'Decrement Selection', mode = 'x' },
    },
    opts_extend = { 'ensure_installed' },
    ---@type TSConfig
    ---@diagnostic disable-next-line: missing-fields
    opts = {
      highlight = { enable = true },
      indent = { enable = true },
      fold = { enable = true },
      ensure_installed = {
        'bash',
        'c',
        'cmake',
        'cpp',
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
      -- Deduplicate ensure_installed to prevent race conditions during parallel install
      -- See: https://github.com/nvim-treesitter/nvim-treesitter/issues/4680
      if opts.ensure_installed then
        local seen = {}
        local unique = {}
        for _, lang in ipairs(opts.ensure_installed) do
          if not seen[lang] then
            seen[lang] = true
            table.insert(unique, lang)
          end
        end
        opts.ensure_installed = unique
      end
      require('nvim-treesitter.configs').setup(opts)
    end,
  },

  --[[
    nvim-treesitter-textobjects - Enhanced Navigation
    
    Provides text objects and motions based on treesitter syntax:
    - Move between functions, classes, parameters
    - Falls back to vim's default behavior in diff mode
  ]]
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

  -- Treesitter context (shows current function/class at top of buffer)
  {
    'nvim-treesitter/nvim-treesitter-context',
    event = 'VeryLazy',
    opts = {
      max_lines = 3,
      min_window_height = 20,
    },
    keys = {
      {
        '<leader>ut',
        function()
          require('treesitter-context').toggle()
        end,
        desc = 'Toggle Treesitter Context',
      },
    },
  },
}
