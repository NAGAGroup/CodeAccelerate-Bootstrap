--[[
=====================================================================
            Neovim Configuration - Keymap Documentation
=====================================================================
This module provides utilities for documenting and viewing keymaps.
]]

local M = {}

-- Store all registered keymaps with documentation
M.keymap_registry = {}

-- Categories for organizing keymaps
M.categories = {
  ["core"] = {
    name = "Core Navigation & Editing",
    description = "Basic editing and navigation commands",
    priority = 10,
  },
  ["lsp"] = {
    name = "Language Server Protocol",
    description = "Code intelligence features (go to definition, find references, etc.)",
    priority = 20,
  },
  ["files"] = {
    name = "File Operations",
    description = "File browsing, searching and management",
    priority = 30,
  },
  ["ui"] = {
    name = "UI Elements",
    description = "UI toggles and visual elements",
    priority = 40,
  },
  ["git"] = {
    name = "Git Integration",
    description = "Git commands and workflows",
    priority = 50,
  },
  ["debug"] = {
    name = "Debugging",
    description = "Debug workflow commands",
    priority = 60,
  },
  ["terminal"] = {
    name = "Terminal",
    description = "Terminal integration",
    priority = 70,
  },
  ["plugin"] = {
    name = "Plugin Specific",
    description = "Commands for specific plugins",
    priority = 80,
  },
  ["misc"] = {
    name = "Miscellaneous",
    description = "Other commands",
    priority = 90,
  },
}

-- Register a keymap with documentation
function M.register(mode, lhs, rhs, opts, category)
  category = category or "misc"
  
  -- Create category if it doesn't exist
  if not M.categories[category] then
    M.categories[category] = {
      name = category:gsub("^%l", string.upper),
      description = "Custom category",
      priority = 100,
    }
  end
  
  -- Add to registry
  table.insert(M.keymap_registry, {
    mode = mode,
    lhs = lhs,
    rhs = rhs,
    opts = opts or {},
    category = category,
    desc = opts and opts.desc or "No description",
  })
  
  -- Also create the actual keymap
  return vim.keymap.set(mode, lhs, rhs, opts)
end

-- Group helper for registering multiple keymaps with the same options and category
function M.register_group(mode, maps, options, category)
  options = options or { silent = true }
  category = category or "misc"
  
  for _, map in ipairs(maps) do
    local lhs, rhs, desc = unpack(map)
    local opts = vim.tbl_extend('force', options, { desc = desc })
    M.register(mode, lhs, rhs, opts, category)
  end
end

-- Format a keymap for display
function M.format_keymap(keymap)
  local mode_map = {
    n = "Normal",
    i = "Insert",
    v = "Visual",
    x = "Visual",
    s = "Select",
    c = "Command",
    t = "Terminal",
  }
  
  local mode_display = mode_map[keymap.mode] or keymap.mode
  return string.format("%-10s %-20s %-50s", mode_display, keymap.lhs, keymap.desc)
end

-- Show all registered keymaps in a float window
function M.show_keymaps()
  -- Sort categories by priority
  local sorted_categories = {}
  for cat_id, cat in pairs(M.categories) do
    table.insert(sorted_categories, { id = cat_id, data = cat })
  end
  
  table.sort(sorted_categories, function(a, b)
    return a.data.priority < b.data.priority
  end)
  
  -- Generate content
  local content = {
    "# Keymap Documentation",
    "",
    "This is a comprehensive list of keymaps available in this Neovim configuration.",
    "",
  }
  
  -- Display keymaps by category
  for _, cat in ipairs(sorted_categories) do
    local cat_id = cat.id
    local cat_data = cat.data
    
    -- Get keymaps for this category
    local category_maps = {}
    for _, keymap in ipairs(M.keymap_registry) do
      if keymap.category == cat_id then
        table.insert(category_maps, keymap)
      end
    end
    
    -- Skip empty categories
    if #category_maps > 0 then
      table.insert(content, "## " .. cat_data.name)
      table.insert(content, "")
      table.insert(content, cat_data.description)
      table.insert(content, "")
      table.insert(content, "```")
      table.insert(content, "MODE       KEY                  DESCRIPTION")
      table.insert(content, "--------------------------------------------------------")
      
      for _, keymap in ipairs(category_maps) do
        table.insert(content, M.format_keymap(keymap))
      end
      
      table.insert(content, "```")
      table.insert(content, "")
    end
  end
  
  -- Create buffer for documentation
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)
  
  -- Set buffer options
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)
  vim.api.nvim_buf_set_option(buf, 'filetype', 'markdown')
  
  -- Calculate window size
  local width = math.min(100, vim.o.columns - 10)
  local height = math.min(40, vim.o.lines - 6)
  
  -- Create window
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = 'minimal',
    border = 'rounded',
    title = ' Keymap Documentation ',
    title_pos = 'center',
  })
  
  -- Set window options
  vim.api.nvim_win_set_option(win, 'conceallevel', 2)
  vim.api.nvim_win_set_option(win, 'concealcursor', 'nc')
  
  -- Set keymaps for the documentation window
  vim.api.nvim_buf_set_keymap(buf, 'n', 'q', '<cmd>close<CR>', { silent = true, noremap = true })
  vim.api.nvim_buf_set_keymap(buf, 'n', '<Esc>', '<cmd>close<CR>', { silent = true, noremap = true })
end

-- Generate markdown documentation for all keymaps
function M.generate_markdown()
  local lines = {
    "# Neovim Keymap Documentation",
    "",
    "This document contains all keymaps configured in this Neovim setup.",
    "",
  }
  
  -- Sort categories by priority
  local sorted_categories = {}
  for cat_id, cat in pairs(M.categories) do
    table.insert(sorted_categories, { id = cat_id, data = cat })
  end
  
  table.sort(sorted_categories, function(a, b)
    return a.data.priority < b.data.priority
  end)
  
  -- Generate content by category
  for _, cat in ipairs(sorted_categories) do
    local cat_id = cat.id
    local cat_data = cat.data
    
    -- Get keymaps for this category
    local category_maps = {}
    for _, keymap in ipairs(M.keymap_registry) do
      if keymap.category == cat_id then
        table.insert(category_maps, keymap)
      end
    end
    
    -- Skip empty categories
    if #category_maps > 0 then
      table.insert(lines, "## " .. cat_data.name)
      table.insert(lines, "")
      table.insert(lines, cat_data.description)
      table.insert(lines, "")
      table.insert(lines, "| Mode | Key | Description |")
      table.insert(lines, "|------|-----|-------------|")
      
      for _, keymap in ipairs(category_maps) do
        local mode_map = {
          n = "Normal",
          i = "Insert",
          v = "Visual",
          x = "Visual",
          s = "Select",
          c = "Command",
          t = "Terminal",
        }
        
        local mode_display = mode_map[keymap.mode] or keymap.mode
        table.insert(lines, string.format("| %s | `%s` | %s |", 
                                        mode_display, 
                                        keymap.lhs:gsub("|", "\\|"), 
                                        keymap.desc:gsub("|", "\\|")))
      end
      
      table.insert(lines, "")
    end
  end
  
  return table.concat(lines, "\n")
end

return M