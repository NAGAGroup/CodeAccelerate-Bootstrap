-- =============================================================================
-- navigation.lua — Navigation configuration for Neovim v0.12
-- =============================================================================

-- =============================================================================
-- Section 1 — root.lua utility (local alias)
-- =============================================================================

local root = require('config.root')

-- =============================================================================
-- Section 2 — mini.files
-- =============================================================================

require('mini.files').setup({})

vim.api.nvim_create_autocmd('User', {
  pattern  = 'MiniFilesBufferCreate',
  callback = function(args)
    local buf = args.data.buf_id

    -- gy: yank absolute path of current entry
    vim.keymap.set('n', 'gy', function()
      local entry = MiniFiles.get_fs_entry()
      if entry then vim.fn.setreg(vim.v.register, entry.path) end
    end, { buffer = buf, desc = 'Yank absolute path' })

    -- gY: yank relative path of current entry
    vim.keymap.set('n', 'gY', function()
      local entry = MiniFiles.get_fs_entry()
      if entry then
        vim.fn.setreg(vim.v.register, vim.fn.fnamemodify(entry.path, ':.'))
      end
    end, { buffer = buf, desc = 'Yank relative path' })

    -- gn: yank filename only
    vim.keymap.set('n', 'gn', function()
      local entry = MiniFiles.get_fs_entry()
      if entry then
        vim.fn.setreg(vim.v.register, vim.fn.fnamemodify(entry.path, ':t'))
      end
    end, { buffer = buf, desc = 'Yank filename' })
  end,
  desc = 'Register mini.files in-buffer keymaps',
})

vim.keymap.set('n', '<leader>e', function()
  MiniFiles.open(vim.api.nvim_buf_get_name(0))
end, { desc = 'Open file explorer (current file)' })

vim.keymap.set('n', '<leader>E', function()
  MiniFiles.open()
end, { desc = 'Open file explorer (cwd)' })

-- =============================================================================
-- Section 3 — snacks.nvim picker keymaps
-- =============================================================================
-- NOTE: require('snacks').setup() is already done in ui.lua
-- Do NOT call it again here

-- Find (root-aware)
vim.keymap.set('n', '<leader>ff', function() Snacks.picker.files({ cwd = root.detect() }) end,
  { desc = 'Find files (root)' })
vim.keymap.set('n', '<leader>fg', function() Snacks.picker.grep({ cwd = root.detect() }) end,
  { desc = 'Live grep (root)' })
vim.keymap.set('n', '<leader>fG', function() Snacks.picker.git_files({ cwd = root.detect() }) end,
  { desc = 'Git files (root)' })

-- Find (no root)
vim.keymap.set('n', '<leader>fb', function() Snacks.picker.buffers() end,
  { desc = 'Find buffers' })
vim.keymap.set('n', '<leader>fh', function() Snacks.picker.help() end,
  { desc = 'Find help' })
vim.keymap.set('n', '<leader>fr', function() Snacks.picker.recent() end,
  { desc = 'Recent files' })
vim.keymap.set('n', '<leader>fc', function() Snacks.picker.commands() end,
  { desc = 'Commands' })
vim.keymap.set('n', '<leader>fk', function() Snacks.picker.keymaps() end,
  { desc = 'Keymaps' })
vim.keymap.set('n', '<leader>fs', function() Snacks.picker.lsp_symbols() end,
  { desc = 'LSP document symbols' })
vim.keymap.set('n', '<leader>fS', function() Snacks.picker.lsp_workspace_symbols() end,
  { desc = 'LSP workspace symbols' })
vim.keymap.set('n', '<leader>fd', function() Snacks.picker.diagnostics() end,
  { desc = 'Diagnostics' })
vim.keymap.set('n', '<leader>f/', function() Snacks.picker.grep() end,
  { desc = 'Grep (cwd)' })
vim.keymap.set('n', '<leader>fn', function() Snacks.notifier.show_history() end,
  { desc = 'Notification history' })

-- Search aliases
vim.keymap.set('n', '<leader>sg', function() Snacks.picker.grep({ cwd = root.detect() }) end,
  { desc = 'Search grep (project)' })
vim.keymap.set('n', '<leader>ss', function() Snacks.picker.lsp_symbols() end,
  { desc = 'Search document symbols' })
vim.keymap.set('n', '<leader>sS', function() Snacks.picker.lsp_workspace_symbols() end,
  { desc = 'Search workspace symbols' })

-- =============================================================================
-- Section 4 — Global yank path keymaps
-- =============================================================================

vim.keymap.set('n', '<leader>ya', function()
  local path = vim.api.nvim_buf_get_name(0)
  vim.fn.setreg('+', path)
  vim.notify('Yanked: ' .. path, vim.log.levels.INFO)
end, { desc = 'Yank absolute path' })

vim.keymap.set('n', '<leader>yr', function()
  local rel = root.relative_path()
  vim.fn.setreg('+', rel)
  vim.notify('Yanked: ' .. rel, vim.log.levels.INFO)
end, { desc = 'Yank relative path (from root)' })

vim.keymap.set('n', '<leader>yn', function()
  local name = root.filename()
  vim.fn.setreg('+', name)
  vim.notify('Yanked: ' .. name, vim.log.levels.INFO)
end, { desc = 'Yank filename' })

-- =============================================================================
-- Section 5 — harpoon2
-- =============================================================================

local harpoon = require('harpoon')
harpoon:setup()  -- REQUIRED before any harpoon operations

vim.keymap.set('n', '<leader>a', function() harpoon:list():add() end,
  { desc = 'Harpoon: add file' })
vim.keymap.set('n', '<C-e>', function() harpoon.ui:toggle_quick_menu(harpoon:list()) end,
  { desc = 'Harpoon: toggle menu' })
vim.keymap.set('n', '<leader>1', function() harpoon:list():select(1) end,
  { desc = 'Harpoon: file 1' })
vim.keymap.set('n', '<leader>2', function() harpoon:list():select(2) end,
  { desc = 'Harpoon: file 2' })
vim.keymap.set('n', '<leader>3', function() harpoon:list():select(3) end,
  { desc = 'Harpoon: file 3' })
vim.keymap.set('n', '<leader>4', function() harpoon:list():select(4) end,
  { desc = 'Harpoon: file 4' })
