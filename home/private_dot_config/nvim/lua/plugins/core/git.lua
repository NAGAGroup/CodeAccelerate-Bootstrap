--[[
=====================================================================
                    Neovim Plugins - Git Integration
=====================================================================

This file configures plugins for Git integration, including gutter
signs, diff viewing, and hunk manipulation.

PLUGIN OVERVIEW:

  Visual Indicators:
    - gitsigns.nvim         : Git change signs in the gutter

  Diff & History:
    - diffview.nvim         : Enhanced diff viewing and file history

KEY MAPPINGS:

  Diffview:
    <leader>gd  : Open diffview
    <leader>gD  : Close diffview
    <leader>gH  : File history (current file)

  Git Signs (Hunks):
    ]h          : Next hunk
    [h          : Previous hunk
    ]H          : Last hunk
    [H          : First hunk

  Git Signs Actions (<leader>gh prefix):
    <leader>ghs : Stage hunk (normal/visual)
    <leader>ghr : Reset hunk (normal/visual)
    <leader>ghS : Stage entire buffer
    <leader>ghu : Undo stage hunk
    <leader>ghR : Reset entire buffer
    <leader>ghp : Preview hunk inline
    <leader>ghb : Blame line
    <leader>ghB : Blame buffer
    <leader>ghd : Diff this
    <leader>ghD : Diff this ~

  Git Signs Text Objects:
    ih          : Select hunk (operator-pending/visual)

  Git Signs Toggle:
    <leader>uG  : Toggle git signs visibility

@see https://github.com/lewis6991/gitsigns.nvim
@see https://github.com/sindrets/diffview.nvim
]]

return {
  -- ============================================================================
  -- GIT INTEGRATION
  -- ============================================================================

  --[[
    diffview.nvim - Enhanced Diff Viewing
    
    Provides a side-by-side diff view with file tree navigation.
    Useful for reviewing changes before commits or exploring history.
  ]]
  {
    'sindrets/diffview.nvim',
    cmd = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewToggleFiles', 'DiffviewFocusFiles', 'DiffviewFileHistory' },
    opts = {},
    keys = {
      { '<leader>gd', '<cmd>DiffviewOpen<cr>', desc = 'Diffview Open' },
      { '<leader>gD', '<cmd>DiffviewClose<cr>', desc = 'Diffview Close' },
      { '<leader>gH', '<cmd>DiffviewFileHistory %<cr>', desc = 'File History (current)' },
    },
  },

  -- Git signs in the gutter
  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
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
    config = function(_, opts)
      require('gitsigns').setup(opts)

      -- Toggle for git signs
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
}
