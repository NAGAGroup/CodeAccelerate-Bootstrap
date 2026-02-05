-- Treesitter configuration

local add, now = MiniDeps.add, MiniDeps.now

now(function()
  add {
    source = 'nvim-treesitter/nvim-treesitter',
    hooks = {
      post_checkout = function()
        -- mini.deps keeps plugins in opt/; ensure command exists
        pcall(vim.cmd, 'packadd nvim-treesitter')
        pcall(vim.cmd, 'TSUpdate')
      end,
    },
  }

  add 'nvim-treesitter/nvim-treesitter-textobjects'

  local function setup_treesitter()
    -- mini.deps installs into pack/deps/opt/*; make sure runtimepath is set
    local ok_pack_ts = pcall(vim.cmd, 'packadd nvim-treesitter')
    local ok_pack_to = pcall(vim.cmd, 'packadd nvim-treesitter-textobjects')

    if not ok_pack_ts or not ok_pack_to then
      return false
    end

    local ok_configs, configs = pcall(require, 'nvim-treesitter.configs')
    if not ok_configs then
      return false
    end

    configs.setup {
      ensure_installed = {
        'c',
        'cpp',
        'cmake',
        'python',
        'javascript',
        'typescript',
        'tsx',
        'bash',
        'nu',
        'json',
        'yaml',
        'toml',
        'markdown',
        'markdown_inline',
        'lua',
        'vim',
        'vimdoc',
        'query',
      },
      auto_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      indent = {
        enable = true,
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
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ['af'] = '@function.outer',
            ['if'] = '@function.inner',
            ['ac'] = '@class.outer',
            ['ic'] = '@class.inner',
            ['aa'] = '@parameter.outer',
            ['ia'] = '@parameter.inner',
          },
        },
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = {
            [']f'] = '@function.outer',
            [']c'] = '@class.outer',
          },
          goto_next_end = {
            [']F'] = '@function.outer',
            [']C'] = '@class.outer',
          },
          goto_previous_start = {
            ['[f'] = '@function.outer',
            ['[c'] = '@class.outer',
          },
          goto_previous_end = {
            ['[F'] = '@function.outer',
            ['[C'] = '@class.outer',
          },
        },
      },
    }

    -- Auto-install missing parsers on FileType open.
    if vim.g.treesitter_auto_install ~= false then
      local ok_parsers, parsers = pcall(require, 'nvim-treesitter.parsers')
      local ok_install, install = pcall(require, 'nvim-treesitter.install')
      if ok_parsers and ok_install then
        local seen = {}
        vim.api.nvim_create_autocmd('FileType', {
          group = vim.api.nvim_create_augroup('treesitter_auto_install', { clear = true }),
          callback = function(ev)
            local ft = vim.bo[ev.buf].filetype
            if not ft or ft == '' then
              return
            end

            local lang = vim.treesitter.language.get_lang(ft) or ft
            if seen[lang] then
              return
            end

            if not parsers.has_parser(lang) then
              seen[lang] = true
              pcall(install.install, lang)
            end
          end,
        })
      end
    end

    -- Always start Treesitter highlighting when a buffer's FileType is set.
    vim.api.nvim_create_autocmd('FileType', {
      group = vim.api.nvim_create_augroup('treesitter_auto_start', { clear = true }),
      callback = function(ev)
        local ok_parsers, parsers = pcall(require, 'nvim-treesitter.parsers')
        if not ok_parsers then return end
        local ft = vim.bo[ev.buf].filetype
        if not ft or ft == '' then return end
        local lang = vim.treesitter.language.get_lang(ft) or ft
        if not parsers.has_parser(lang) then return end
        pcall(vim.treesitter.start, ev.buf, lang)
      end,
    })

    return true
  end

  -- Avoid hard failure on first launch if plugin isn't on runtimepath yet.
  if not setup_treesitter() then
    vim.api.nvim_create_autocmd('VimEnter', {
      group = vim.api.nvim_create_augroup('treesitter_deferred_setup', { clear = true }),
      once = true,
      callback = function()
        -- Retry once after UI is up
        setup_treesitter()
      end,
    })
  end
end)
