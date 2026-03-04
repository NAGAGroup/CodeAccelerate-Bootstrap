-- Dynamic feature toggles (LazyVim-style)
-- All toggles persist for the session and notify their new state.
-- Keymaps are under <leader>u (UI/Toggles group).

local map = vim.keymap.set

-- Utility: notify toggle state
local function notify_toggle(feature, enabled)
  local state = enabled and "enabled" or "disabled"
  local icon = enabled and "  " or "  "
  vim.notify(icon .. feature .. " " .. state, vim.log.levels.INFO, { title = "Toggle" })
end

-- ─── Format on save ───────────────────────────────────────────────────────────

-- Global format-on-save flag (checked by formatting.lua autocmd)
vim.g.format_on_save = true

-- Buffer-local override: nil = follow global, true/false = override
-- Per-buffer state is stored in vim.b.format_on_save

local function toggle_format_global()
  vim.g.format_on_save = not vim.g.format_on_save
  notify_toggle("Format on save (global)", vim.g.format_on_save)
end

local function toggle_format_buffer()
  -- If buffer has no override yet, inherit from global then flip
  if vim.b.format_on_save == nil then
    vim.b.format_on_save = not vim.g.format_on_save
  else
    vim.b.format_on_save = not vim.b.format_on_save
  end
  notify_toggle("Format on save (buffer)", vim.b.format_on_save)
end

-- Helper consumed by formatting.lua: should we format this buffer right now?
---@return boolean
function vim.g.should_format()
  -- Buffer override takes precedence over global
  if vim.b.format_on_save ~= nil then
    return vim.b.format_on_save
  end
  return vim.g.format_on_save
end

map("n", "<leader>uf", toggle_format_global, { desc = "Toggle format on save (global)" })
map("n", "<leader>uF", toggle_format_buffer, { desc = "Toggle format on save (buffer)" })

-- ─── Linting ──────────────────────────────────────────────────────────────────

vim.g.linting_enabled = true

local function toggle_linting()
  vim.g.linting_enabled = not vim.g.linting_enabled
  notify_toggle("Linting", vim.g.linting_enabled)
  -- Re-trigger lint (will no-op if disabled) so diagnostics clear immediately
  if not vim.g.linting_enabled then
    vim.diagnostic.reset(nil, vim.api.nvim_get_current_buf())
  else
    vim.schedule(function()
      require("lint").try_lint()
    end)
  end
end

map("n", "<leader>ul", toggle_linting, { desc = "Toggle linting" })

-- ─── Diagnostics ──────────────────────────────────────────────────────────────

-- Track current virtual_text state; start enabled
vim.g.diagnostics_enabled = true

local function toggle_diagnostics()
  vim.g.diagnostics_enabled = not vim.g.diagnostics_enabled
  if vim.g.diagnostics_enabled then
    vim.diagnostic.config({
      virtual_text = true,
      signs = true,
      underline = true,
    })
  else
    vim.diagnostic.config({
      virtual_text = false,
      signs = false,
      underline = false,
    })
  end
  notify_toggle("Diagnostics", vim.g.diagnostics_enabled)
end

map("n", "<leader>ud", toggle_diagnostics, { desc = "Toggle diagnostics" })

-- ─── Inlay hints ──────────────────────────────────────────────────────────────

-- Start enabled (matches vtsls config which enables all hints)
vim.g.inlay_hints_enabled = true

local function toggle_inlay_hints()
  vim.g.inlay_hints_enabled = not vim.g.inlay_hints_enabled
  vim.lsp.inlay_hint.enable(vim.g.inlay_hints_enabled, { bufnr = 0 })
  notify_toggle("Inlay hints", vim.g.inlay_hints_enabled)
end

map("n", "<leader>ui", toggle_inlay_hints, { desc = "Toggle inlay hints" })

-- ─── Spell check ──────────────────────────────────────────────────────────────

local function toggle_spell()
  vim.opt.spell = not vim.opt.spell:get()
  notify_toggle("Spell check", vim.opt.spell:get())
end

map("n", "<leader>us", toggle_spell, { desc = "Toggle spell check" })

-- ─── Word wrap ────────────────────────────────────────────────────────────────

local function toggle_wrap()
  vim.opt.wrap = not vim.opt.wrap:get()
  notify_toggle("Word wrap", vim.opt.wrap:get())
end

map("n", "<leader>uw", toggle_wrap, { desc = "Toggle word wrap" })

-- ─── Relative line numbers ────────────────────────────────────────────────────

local function toggle_relative_numbers()
  vim.opt.relativenumber = not vim.opt.relativenumber:get()
  notify_toggle("Relative numbers", vim.opt.relativenumber:get())
end

map("n", "<leader>un", toggle_relative_numbers, { desc = "Toggle relative numbers" })
