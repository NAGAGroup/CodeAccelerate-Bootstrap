-- =============================================================================
-- treesitter.lua — Native Treesitter Configuration for Neovim v0.12
-- =============================================================================
--
-- IMPORTANT: nvim-treesitter was ARCHIVED on April 3, 2026.
-- This config uses Neovim v0.12 native treesitter instead.
-- nvim-treesitter-textobjects is also archived.
-- FixCursorHold.nvim is NOT needed (CursorHold is fixed natively in v0.12).
--
-- KEYMAP CHANGES from old config (forced by nvim-treesitter archival):
--   OLD (nvim-treesitter-textobjects):   NEW (v0.12 native):
--   af/if  (function outer/inner)   →    an/in  (any node outer/inner)
--   ac/ic  (class outer/inner)      →    an/in  (same — structural selection)
--   ]m/[m  (function start)         →    ]n/[n  (next/prev sibling)
--   ]]/[[  (class start)            →    ]n/[n  (next/prev sibling)
--
-- The native keymaps an/in/]n/[n are auto-configured by v0.12.
-- No explicit keymap setup is needed.
-- See :h treesitter-defaults for full documentation.
-- =============================================================================

-- =============================================================================
-- Treesitter Highlighting
-- =============================================================================
-- vim.treesitter.start() is NOT automatic — must be called per-buffer.
-- Register FileType autocmd to enable treesitter highlighting for all files.

local ts_highlight_group = vim.api.nvim_create_augroup('treesitter_highlight', { clear = true })

vim.api.nvim_create_autocmd('FileType', {
  group    = ts_highlight_group,
  pattern  = '*',
  callback = function()
    -- Only enable if a treesitter parser exists for this filetype
    local ok = pcall(vim.treesitter.start)
    if not ok then
      -- No parser available; fall back to vim regex syntax (already active)
    end
  end,
  desc = 'Enable treesitter highlighting when a parser is available',
})

-- =============================================================================
-- Treesitter Folding
-- =============================================================================
-- Folding is already configured in options.lua:
--   vim.opt.foldmethod    = 'expr'
--   vim.opt.foldexpr      = 'v:lua.vim.treesitter.foldexpr()'
--   vim.opt.foldlevel     = 99
--   vim.opt.foldlevelstart = 99
--   vim.opt.foldcolumn    = '1'
--
-- The BufReadPost + BufNewFile workaround for bug #28692 (fold timing) is
-- already registered in autocmds.lua as the 'treesitter_folds' augroup.
-- No additional folding configuration is needed here.

-- =============================================================================
-- Structural Selection (replaces nvim-treesitter-textobjects)
-- =============================================================================
-- v0.12 auto-maps the following in visual and operator-pending modes:
--   an  = select outward (parent node)      e.g., van, dan, can
--   in  = select inward (child node)        e.g., vin, din, cin
--   ]n  = next sibling node
--   [n  = previous sibling node
--
-- These work automatically when a treesitter parser is attached.
-- Falls back to LSP textDocument/selectionRange if no parser is available.
-- No explicit configuration is needed. See :h treesitter-defaults

-- =============================================================================
-- tree-sitter-manager.nvim — Parser Management
-- =============================================================================
-- Manages installation of additional parsers not bundled with Neovim v0.12.
-- Bundled parsers: c, lua, markdown, markdown_inline, vim, vimdoc, query
-- The following additional parsers are managed here:

require('tree-sitter-manager').setup({
  ensure_installed = {
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
  },
  -- Auto-install parsers when a new filetype is encountered
  -- (fix for auto_install confirmed in main branch)
  auto_install = true,
})
