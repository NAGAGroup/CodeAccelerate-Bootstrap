--[[
=====================================================================
                    Neovim Plugins - Search & Navigation
=====================================================================

This file configures plugins for searching, navigating, and finding
content across the codebase and within buffers.

PLUGIN OVERVIEW:

  Fuzzy Finding:
    - fzf-lua               : Fast fuzzy finder (files, grep, LSP, etc.)

  Diagnostics & Lists:
    - trouble.nvim          : Pretty diagnostics list
    - nvim-bqf              : Better quickfix list
    - todo-comments.nvim    : Highlight and search TODO/FIXME comments

  Search & Replace:
    - grug-far.nvim         : Project-wide search and replace

KEY MAPPINGS:

  FZF-lua (Fuzzy Finding):
    <leader>,   : Switch buffer (MRU sorted)
    <leader>:   : Command history
    <leader>ff  : Find files (cwd)
    <leader>fF  : Find files (root dir)
    <leader>fg  : Find git files
    <leader>fr  : Recent files
    <leader>fb  : Buffers

  Search (<leader>s prefix):
    <leader>sg  : Live grep (cwd)
    <leader>sG  : Live grep (root dir)
    <leader>sw  : Search word under cursor (cwd)
    <leader>sW  : Search word under cursor (root dir)
    <leader>sb  : Search in current buffer
    <leader>ss  : Document symbols (LSP)
    <leader>sS  : Workspace symbols (LSP)
    <leader>sh  : Help pages
    <leader>sk  : Keymaps
    <leader>sr  : Search and replace (cwd)
    <leader>sR  : Search and replace (root dir)

  Trouble (<leader>x prefix):
    <leader>xx  : Toggle diagnostics
    <leader>xX  : Buffer diagnostics
    <leader>xt  : Todo comments
    <leader>xT  : Todo/Fix/Fixme only
    <leader>xL  : Location list
    <leader>xQ  : Quickfix list

  Todo Navigation:
    ]t          : Next todo comment
    [t          : Previous todo comment

  Quickfix Navigation:
    ]q          : Next quickfix/trouble item
    [q          : Previous quickfix/trouble item

  LSP Navigation (via fzf-lua):
    gd          : Go to definition
    gr          : Find references
    gI          : Go to implementation
    gy          : Go to type definition

@see config.lsp_keymaps for additional LSP keybindings
@see https://github.com/ibhagwan/fzf-lua
]]

return {
  -- ============================================================================
  -- SEARCH & NAVIGATION
  -- ============================================================================

  -- Better quickfix list with preview
  {
    'kevinhwang91/nvim-bqf',
    ft = 'qf',
    opts = {},
  },

  --[[
    fzf-lua - Fast Fuzzy Finder
    
    A powerful fuzzy finder that provides:
    - File navigation (find files, git files, recent files)
    - Content search (live grep, buffer search)
    - LSP integration (symbols, definitions, references)
    - Git integration (commits, status, branches)
    - Misc (commands, keymaps, help, marks, etc.)
    
    Uses native fzf for speed and supports image preview.
  ]]
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
      {
        '<leader>fF',
        function()
          local utils = require 'utils.utils'
          require('fzf-lua').files { cwd = utils.get_root() }
        end,
        desc = 'Find Files (root dir)',
      },
      { '<leader>fg', '<cmd>FzfLua git_files<cr>', desc = 'Find Files (git-files)' },
      { '<leader>fr', '<cmd>FzfLua oldfiles<cr>', desc = 'Recent' },
      -- Git
      { '<leader>gc', '<cmd>FzfLua git_commits<CR>', desc = 'Commits' },
      { '<leader>gs', '<cmd>FzfLua git_status<CR>', desc = 'Status' },
      -- Search
      -- Note: Lowercase keybindings (e.g., sg) operate on the current working directory (cwd)
      -- while uppercase keybindings (e.g., sG) operate on the project root directory
      { '<leader>s"', '<cmd>FzfLua registers<cr>', desc = 'Registers' },
      { '<leader>sa', '<cmd>FzfLua autocmds<cr>', desc = 'Auto Commands' },
      { '<leader>sb', '<cmd>FzfLua grep_curbuf<cr>', desc = 'Buffer' },
      { '<leader>sc', '<cmd>FzfLua command_history<cr>', desc = 'Command History' },
      { '<leader>sC', '<cmd>FzfLua commands<cr>', desc = 'Commands' },
      { '<leader>sd', '<cmd>FzfLua diagnostics_document<cr>', desc = 'Document Diagnostics' },
      { '<leader>sD', '<cmd>FzfLua diagnostics_workspace<cr>', desc = 'Workspace Diagnostics' },
      { '<leader>sg', '<cmd>FzfLua live_grep<cr>', desc = 'Grep (cwd)' },
      {
        '<leader>sG',
        function()
          local utils = require 'utils.utils'
          require('fzf-lua').live_grep { cwd = utils.get_root() }
        end,
        desc = 'Grep (root dir)',
      },
      { '<leader>sh', '<cmd>FzfLua help_tags<cr>', desc = 'Help Pages' },
      { '<leader>sH', '<cmd>FzfLua highlights<cr>', desc = 'Search Highlight Groups' },
      { '<leader>sj', '<cmd>FzfLua jumps<cr>', desc = 'Jumplist' },
      { '<leader>sk', '<cmd>FzfLua keymaps<cr>', desc = 'Key Maps' },
      { '<leader>sl', '<cmd>FzfLua loclist<cr>', desc = 'Location List' },
      { '<leader>sM', '<cmd>FzfLua man_pages<cr>', desc = 'Man Pages' },
      { '<leader>sm', '<cmd>FzfLua marks<cr>', desc = 'Jump to Mark' },
      { '<leader>sR', '<cmd>FzfLua resume<cr>', desc = 'Resume' },
      { '<leader>sq', '<cmd>FzfLua quickfix<cr>', desc = 'Quickfix List' },
      { '<leader>sw', '<cmd>FzfLua grep_cword<cr>', desc = 'Word (cwd)' },
      {
        '<leader>sW',
        function()
          local utils = require 'utils.utils'
          require('fzf-lua').grep_cword { cwd = utils.get_root() }
        end,
        desc = 'Word (root dir)',
      },
      { '<leader>sw', '<cmd>FzfLua grep_visual<cr>', mode = 'v', desc = 'Selection (cwd)' },
      {
        '<leader>sW',
        function()
          local utils = require 'utils.utils'
          require('fzf-lua').grep_visual { cwd = utils.get_root() }
        end,
        mode = 'v',
        desc = 'Selection (root dir)',
      },
      -- LSP symbols
      {
        '<leader>ss',
        '<cmd>FzfLua lsp_document_symbols<cr>',
        desc = 'Goto Symbol',
      },
      {
        '<leader>sS',
        '<cmd>FzfLua lsp_live_workspace_symbols<cr>',
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
        desc = 'Search and Replace (cwd)',
      },
      {
        '<leader>sR',
        function()
          local utils = require 'utils.utils'
          local grug = require 'grug-far'
          local ext = vim.bo.buftype == '' and vim.fn.expand '%:e'
          grug.open {
            transient = true,
            cwd = utils.get_root(),
            prefills = {
              filesFilter = ext and ext ~= '' and '*.' .. ext or nil,
            },
          }
        end,
        mode = { 'n', 'v' },
        desc = 'Search and Replace (root dir)',
      },
    },
  },
}
