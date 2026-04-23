-- =============================================================================
-- neovim-ayu — colorscheme configuration
-- =============================================================================
-- Note: vim.cmd.colorscheme('ayu-dark') is called in init.lua after all setups
require('ayu').setup({
  mirage   = false,  -- Use dark variant (not mirage)
  terminal = true,   -- Sync terminal colors with colorscheme
  overrides = {},    -- No custom highlight overrides
})

-- =============================================================================
-- snacks.nvim — indent guides, notifications, word highlighting, bigfile
-- =============================================================================
-- IMPORTANT: dashboard MUST be disabled — conflicts with alpha-nvim
require('snacks').setup({
  dashboard = { enabled = false },  -- Disabled: using alpha-nvim instead
  indent = {
    enabled     = true,
    char        = '│',
    only_scope  = false,
    only_current = false,
  },
  notifier = {
    enabled  = true,
    timeout  = 3000,
    style    = 'compact',
    top_down = true,
    sort     = { 'level', 'added' },
  },
  words = {
    enabled = true,  -- Auto-highlight LSP word references under cursor
  },
  bigfile = {
    enabled = true,  -- Disable expensive features for large files
  },
  picker = { enabled = true },
})

-- =============================================================================
-- alpha-nvim — startup dashboard
-- =============================================================================
local alpha = require('alpha')
local dashboard = require('alpha.themes.dashboard')

-- Custom ASCII header
dashboard.section.header.val = {
  '███╗   ██╗██╗   ██╗██╗███╗   ███╗',
  '████╗  ██║██║   ██║██║████╗ ████║',
  '██╔██╗ ██║██║   ██║██║██╔████╔██║',
  '██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║',
  '██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║',
  '╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝',
}

-- Dashboard buttons
dashboard.section.buttons.val = {
  dashboard.button('e', '  New file',       ':enew<CR>'),
  dashboard.button('f', '  Find file',      function() Snacks.picker.files() end),
  dashboard.button('s', '  Restore session', function() require('persistence').load() end),
  dashboard.button('q', '  Quit',           ':qa<CR>'),
}

-- Footer
dashboard.section.footer.val = ''

alpha.setup(dashboard.config)

-- Hide tabline when dashboard is active; restore it when leaving
local alpha_group = vim.api.nvim_create_augroup('alpha_tabline', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
  group    = alpha_group,
  pattern  = 'alpha',
  callback = function() vim.opt.showtabline = 0 end,
  desc     = 'Hide tabline on alpha dashboard',
})
vim.api.nvim_create_autocmd('BufUnload', {
  group    = alpha_group,
  pattern  = '*',
  callback = function()
    if vim.bo.filetype ~= 'alpha' then
      vim.opt.showtabline = 2
    end
  end,
  desc = 'Restore tabline when leaving alpha dashboard',
})

-- =============================================================================
-- lualine.nvim — statusline
-- =============================================================================
-- Theme name is 'ayu' (NOT 'ayu_dark') — provided by neovim-ayu colorscheme
require('lualine').setup({
  options = {
    theme = 'ayu',  -- ← MUST be 'ayu', not 'ayu_dark'
    component_separators = { left = '', right = '' },  -- Powerline thin
    section_separators   = { left = '', right = '' },  -- Powerline arrows
    globalstatus         = true,
    disabled_filetypes   = {
      statusline = { 'alpha', 'snacks_dashboard' },
    },
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { 'branch', 'diff', 'diagnostics' },
    lualine_c = { { 'filename', path = 1 } },  -- path=1 = relative path
    lualine_x = { 'encoding', 'fileformat', 'filetype' },
    lualine_y = { 'progress' },
    lualine_z = { 'location' },
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { 'filename' },
    lualine_x = { 'location' },
    lualine_y = {},
    lualine_z = {},
  },
})

-- =============================================================================
-- bufferline.nvim — buffer tabs
-- =============================================================================
require('bufferline').setup({
  options = {
    mode           = 'buffers',
    separator_style = 'thin',
    diagnostics    = 'nvim_lsp',
    diagnostics_indicator = function(count, level, _diagnostics_dict, _context)
      local icon = level:match('error') and ' ' or ' '
      return ' ' .. icon .. count
    end,
    always_show_bufferline = true,
    offsets = {
      {
        filetype   = 'neo-tree',
        text       = 'File Explorer',
        highlight  = 'Directory',
        separator  = true,
      },
    },
  },
})

-- Buffer navigation keymaps
vim.keymap.set('n', '<leader>bp', '<cmd>BufferLinePick<cr>',      { desc = 'Pick buffer' })
vim.keymap.set('n', '<leader>bc', '<cmd>BufferLinePickClose<cr>', { desc = 'Close buffer (pick)' })

-- =============================================================================
-- which-key.nvim — keymap hints
-- =============================================================================
-- NOTE: which-key v3 — register() is deprecated; use add() instead
require('which-key').setup({
  preset = 'classic',
  win = {
    border = 'rounded',
  },
})

-- Register leader group labels using v3 add() API
require('which-key').add({
  { '<leader>c',  group = 'Code' },
  { '<leader>cm', group = 'CMake' },
  { '<leader>f',  group = 'Find' },
  { '<leader>s',  group = 'Search' },
  { '<leader>t',  group = 'Test' },
  { '<leader>g',  group = 'Git' },
  { '<leader>x',  group = 'Diagnostics' },
  { '<leader>q',  group = 'Session' },
  { '<leader>qq', desc = 'Quit all' },
  { '<leader>qs', desc = 'Session: select' },
  { '<leader>ql', desc = 'Session: restore (cwd)' },
  { '<leader>qS', desc = 'Session: restore last' },
  { '<leader>qd', desc = "Session: don't save on exit" },
  { '<leader>w',  group = 'File' },
  { '<leader>d',  group = 'Debug' },
  { '<leader>r',  group = 'Refactor' },
  { '<leader>b',  group = 'Buffer' },
  { '<leader>y',  group = 'Yank' },
  { '<leader>u',  group = 'UI Toggles' },
})

-- =============================================================================
-- trouble.nvim — diagnostics panel
-- =============================================================================
-- NOTE: trouble v3 — command syntax changed from TroubleToggle to Trouble <mode> toggle
require('trouble').setup({
  focus = false,  -- Default in v3: don't steal focus on open
})

-- Trouble keymaps (v3 command syntax)
vim.keymap.set('n', '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>',
  { desc = 'Diagnostics (Trouble)' })
vim.keymap.set('n', '<leader>xX', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
  { desc = 'Buffer diagnostics (Trouble)' })
vim.keymap.set('n', '<leader>xs', '<cmd>Trouble symbols toggle focus=false<cr>',
  { desc = 'Symbols (Trouble)' })
vim.keymap.set('n', '<leader>xl', '<cmd>Trouble lsp toggle focus=false win.position=right<cr>',
  { desc = 'LSP definitions/references (Trouble)' })
vim.keymap.set('n', '<leader>xL', '<cmd>Trouble loclist toggle<cr>',
  { desc = 'Location list (Trouble)' })
vim.keymap.set('n', '<leader>xQ', '<cmd>Trouble qflist toggle<cr>',
  { desc = 'Quickfix list (Trouble)' })
