-- Navigation, files, and fuzzy finder

local add = MiniDeps.add

-- fzf-lua (fuzzy finder)
add 'ibhagwan/fzf-lua'

require('fzf-lua').setup {
  winopts = {
    height = 0.85,
    width = 0.80,
    preview = {
      horizontal = 'right:50%',
    },
  },
}

-- Use root detection for project searches
local root = require 'core.root'

local function fzf_files()
  local cwd = root.detect()
  require('fzf-lua').files { cwd = cwd }
end

local function fzf_grep()
  local cwd = root.detect()
  require('fzf-lua').live_grep { cwd = cwd }
end

local function fzf_grep_word()
  local cwd = root.detect()
  require('fzf-lua').grep_cword { cwd = cwd }
end

local function fzf_grep_WORD()
  local cwd = root.detect()
  require('fzf-lua').grep_cWORD { cwd = cwd }
end

vim.keymap.set('n', '<leader>ff', fzf_files, { desc = 'Find files' })
vim.keymap.set('n', '<leader>fg', fzf_grep, { desc = 'Live grep' })
vim.keymap.set('n', '<leader>fb', '<cmd>FzfLua buffers<CR>', { desc = 'Find buffers' })
vim.keymap.set('n', '<leader>fh', '<cmd>FzfLua help_tags<CR>', { desc = 'Find help' })
vim.keymap.set('n', '<leader>fr', '<cmd>FzfLua oldfiles<CR>', { desc = 'Recent files' })
vim.keymap.set('n', '<leader>fc', '<cmd>FzfLua commands<CR>', { desc = 'Commands' })
vim.keymap.set('n', '<leader>fk', '<cmd>FzfLua keymaps<CR>', { desc = 'Keymaps' })
vim.keymap.set('n', '<leader>fs', '<cmd>FzfLua lsp_document_symbols<CR>', { desc = 'Document symbols' })
vim.keymap.set('n', '<leader>fS', '<cmd>FzfLua lsp_workspace_symbols<CR>', { desc = 'Workspace symbols' })

-- Search-style aliases (similar to common "old config" layouts)
vim.keymap.set('n', '<leader>sg', fzf_grep, { desc = 'Search grep (project)' })
vim.keymap.set('n', '<leader>sw', fzf_grep_word, { desc = 'Search word under cursor' })
vim.keymap.set('n', '<leader>sW', fzf_grep_WORD, { desc = 'Search WORD under cursor' })
vim.keymap.set('n', '<leader>ss', '<cmd>FzfLua lsp_document_symbols<CR>', { desc = 'Search document symbols' })
vim.keymap.set('n', '<leader>sS', '<cmd>FzfLua lsp_workspace_symbols<CR>', { desc = 'Search workspace symbols' })
vim.keymap.set('n', '<leader>sr', '<cmd>FzfLua resume<CR>', { desc = 'Search resume' })

-- mini.files (file explorer)
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
