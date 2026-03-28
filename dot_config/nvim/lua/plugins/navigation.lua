-- Navigation, files, and fuzzy finder

local add = MiniDeps.add

-- snacks.nvim (must load EARLY for initialization)
add({ source = "folke/snacks.nvim" })
require("snacks").setup({
  picker = { enabled = true },
  notifier = { enabled = true },
  words = { enabled = true },
  indent = { enabled = true },
  bigfile = { enabled = true },
  dashboard = { enabled = false },
  terminal = { enabled = false },
  scratch = { enabled = false },
  scroll = { enabled = false },
  statuscolumn = { enabled = false },
  animate = { enabled = false },
})

-- Helper for root-aware pickers
local function root()
  local r = require('core.root')
  return r.detect and r.detect() or vim.fn.getcwd()
end

-- Snacks picker keymaps
local map = vim.keymap.set
map('n', '<leader>ff', function() Snacks.picker.files({ cwd = root() }) end, { desc = 'Find files (root)' })
map('n', '<leader>fg', function() Snacks.picker.grep({ cwd = root() }) end, { desc = 'Live grep (root)' })
map('n', '<leader>fb', function() Snacks.picker.buffers() end, { desc = 'Find buffers' })
map('n', '<leader>fh', function() Snacks.picker.help() end, { desc = 'Find help' })
map('n', '<leader>fr', function() Snacks.picker.recent() end, { desc = 'Recent files' })
map('n', '<leader>fc', function() Snacks.picker.commands() end, { desc = 'Commands' })
map('n', '<leader>fk', function() Snacks.picker.keymaps() end, { desc = 'Keymaps' })
map('n', '<leader>fs', function() Snacks.picker.lsp_symbols() end, { desc = 'LSP symbols' })
map('n', '<leader>fS', function() Snacks.picker.lsp_workspace_symbols() end, { desc = 'LSP workspace symbols' })
map('n', '<leader>fd', function() Snacks.picker.diagnostics() end, { desc = 'Diagnostics' })
map('n', '<leader>fG', function() Snacks.picker.git_files({ cwd = root() }) end, { desc = 'Git files' })
map('n', '<leader>f/', function() Snacks.picker.grep() end, { desc = 'Grep (cwd)' })
-- Snacks notifier log
map('n', '<leader>fn', function() Snacks.notifier.show_history() end, { desc = 'Notification history' })

-- Search-style aliases (using snacks pickers)
map('n', '<leader>sg', function() Snacks.picker.grep({ cwd = root() }) end, { desc = 'Search grep (project)' })
map('n', '<leader>ss', function() Snacks.picker.lsp_symbols() end, { desc = 'Search document symbols' })
map('n', '<leader>sS', function() Snacks.picker.lsp_workspace_symbols() end, { desc = 'Search workspace symbols' })

-- mini.files (file explorer)
MiniDeps.later(function()
  require('mini.files').setup {
    windows = {
      preview = true,
      width_focus = 30,
      width_preview = 50,
    },
    options = {
      use_as_default_explorer = true,
    },
  }

  -- Toggle mini.files
  vim.keymap.set('n', '<leader>e', function()
    require('mini.files').open(vim.api.nvim_buf_get_name(0))
  end, { desc = 'Open file explorer' })

  vim.keymap.set('n', '<leader>E', function()
    require('mini.files').open()
  end, { desc = 'Open file explorer (cwd)' })

  -- Yank path mappings in mini.files
  local yank_path_in_explorer = function(path_type)
    local root = require 'core.root'
    local MiniFiles = require 'mini.files'

    return function()
      local entry = MiniFiles.get_fs_entry()
      if not entry then
        vim.notify('No entry selected', vim.log.levels.WARN)
        return
      end

      local path
      if path_type == 'absolute' then
        path = entry.path
      elseif path_type == 'relative' then
        local root_dir = root.detect()
        path = entry.path:gsub('^' .. vim.pesc(root_dir) .. '/', '')
      elseif path_type == 'filename' then
        path = vim.fn.fnamemodify(entry.path, ':t')
      end

      vim.fn.setreg('+', path)
      vim.notify('Copied: ' .. path, vim.log.levels.INFO)
    end
  end

  vim.api.nvim_create_autocmd('User', {
    pattern = 'MiniFilesBufferCreate',
    callback = function(args)
      local buf_id = args.data.buf_id
      vim.keymap.set('n', 'gy', yank_path_in_explorer 'absolute', { buffer = buf_id, desc = 'Yank absolute path' })
      vim.keymap.set('n', 'gY', yank_path_in_explorer 'relative', { buffer = buf_id, desc = 'Yank relative path' })
      vim.keymap.set('n', 'gn', yank_path_in_explorer 'filename', { buffer = buf_id, desc = 'Yank filename' })
    end,
  })
end)

-- Global yank path keymaps
local root = require 'core.root'

vim.keymap.set('n', '<leader>ya', function()
  local path = vim.api.nvim_buf_get_name(0)
  vim.fn.setreg('+', path)
  vim.notify('Copied: ' .. path, vim.log.levels.INFO)
end, { desc = 'Yank absolute path' })

vim.keymap.set('n', '<leader>yr', function()
  local path = root.relative_path()
  vim.fn.setreg('+', path)
  vim.notify('Copied: ' .. path, vim.log.levels.INFO)
end, { desc = 'Yank relative path' })

vim.keymap.set('n', '<leader>yn', function()
  local path = root.filename()
  vim.fn.setreg('+', path)
  vim.notify('Copied: ' .. path, vim.log.levels.INFO)
end, { desc = 'Yank filename' })

-- Harpoon2 (quick marks)
add {
  source = 'ThePrimeagen/harpoon',
  checkout = 'harpoon2',
  depends = { 'nvim-lua/plenary.nvim' },
}

local harpoon = require 'harpoon'
harpoon:setup()

vim.keymap.set('n', '<leader>a', function()
  harpoon:list():add()
end, { desc = 'Add file to harpoon' })

vim.keymap.set('n', '<C-e>', function()
  harpoon.ui:toggle_quick_menu(harpoon:list())
end, { desc = 'Toggle harpoon menu' })

vim.keymap.set('n', '<leader>1', function()
  harpoon:list():select(1)
end, { desc = 'Harpoon file 1' })

vim.keymap.set('n', '<leader>2', function()
  harpoon:list():select(2)
end, { desc = 'Harpoon file 2' })

vim.keymap.set('n', '<leader>3', function()
  harpoon:list():select(3)
end, { desc = 'Harpoon file 3' })

vim.keymap.set('n', '<leader>4', function()
  harpoon:list():select(4)
end, { desc = 'Harpoon file 4' })
