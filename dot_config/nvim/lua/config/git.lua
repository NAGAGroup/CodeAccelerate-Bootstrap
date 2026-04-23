-- =============================================================================
-- git.lua — Git integration via gitsigns.nvim
-- =============================================================================

require('gitsigns').setup({
  -- Gutter signs (v2.0+: only 'text' field; hl/numhl/linehl removed)
  signs = {
    add          = { text = '│' },   -- U+2502 box drawings light vertical
    change       = { text = '│' },   -- U+2502 box drawings light vertical
    delete       = { text = '_' },   -- underscore
    topdelete    = { text = '‾' },   -- U+203E overline
    changedelete = { text = '~' },   -- tilde
    untracked    = { text = '┆' },   -- U+2506 box drawings light triple dash vertical
  },
  -- Staged signs (mirrors unstaged for consistent display)
  signs_staged = {
    add          = { text = '│' },
    change       = { text = '│' },
    delete       = { text = '_' },
    topdelete    = { text = '‾' },
    changedelete = { text = '~' },
    untracked    = { text = '┆' },
  },
  signs_staged_enable = true,

  on_attach = function(bufnr)
    local gs = require('gitsigns')

    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
    end

    -- Hunk navigation (use nav_hunk — next_hunk/prev_hunk are deprecated)
    map('n', ']h', function() gs.nav_hunk('next') end, 'Git: next hunk')
    map('n', '[h', function() gs.nav_hunk('prev') end, 'Git: prev hunk')

    -- Stage / Reset hunks (normal mode)
    map('n', '<leader>gs', function() gs.stage_hunk() end,         'Git: stage hunk')
    map('n', '<leader>gr', function() gs.reset_hunk() end,         'Git: reset hunk')

    -- Stage / Reset hunks (visual mode — pass line range)
    map('v', '<leader>gs', function()
      gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
    end, 'Git: stage hunk (visual)')
    map('v', '<leader>gr', function()
      gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
    end, 'Git: reset hunk (visual)')

    -- Buffer-level operations
    map('n', '<leader>gS', function() gs.stage_buffer() end,       'Git: stage buffer')
    map('n', '<leader>gu', function() gs.undo_stage_hunk() end,    'Git: undo stage hunk')  -- deprecated but preserved for parity
    map('n', '<leader>gR', function() gs.reset_buffer() end,       'Git: reset buffer')

    -- Inspect / View
    map('n', '<leader>gp', function() gs.preview_hunk() end,       'Git: preview hunk')
    map('n', '<leader>gb', function() gs.blame_line({ full = true }) end, 'Git: blame line')

    -- Toggles
    map('n', '<leader>gtb', function() gs.toggle_current_line_blame() end, 'Git: toggle line blame')
    map('n', '<leader>gd',  function() gs.diffthis() end,          'Git: diff this')
    map('n', '<leader>gD',  function() gs.diffthis('~') end,       'Git: diff against ~')
    map('n', '<leader>gtd', function() gs.toggle_deleted() end,    'Git: toggle deleted')  -- deprecated but preserved for parity

     -- Text object: ih = select hunk (in both visual/operator-pending modes)
     map({ 'o', 'x' }, 'ih', function() gs.select_hunk() end, 'Git: select hunk (text object)')
   end,
})

-- Register which-key group for git toggles
local ok, wk = pcall(require, 'which-key')
if ok then
  wk.add({ { '<leader>gt', group = 'Git Toggles' } })
end
