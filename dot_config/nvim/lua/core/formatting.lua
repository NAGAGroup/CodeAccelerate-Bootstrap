-- Formatting via conform.nvim

local add = MiniDeps.add
add("stevearc/conform.nvim")

local ok, err = pcall(function()
  require("conform").setup({
    formatters_by_ft = {
      -- C/C++
      -- c = { "clang-format" },
      -- cpp = { "clang-format" },

      -- Python
      python = { "ruff_format" },

      -- JavaScript/TypeScript
      javascript = { "biome" },
      typescript = { "biome" },
      javascriptreact = { "biome" },
      typescriptreact = { "biome" },

      -- Shell
      bash = { "shfmt" },
      sh = { "shfmt" },

      -- Config formats
      json = { "biome" },
      yaml = { "prettier" },
      toml = { "taplo" },

      -- Markdown
      -- markdown = { 'mdformat' },

      -- Lua
      lua = { "stylua" },
    },
    -- format_on_save is gated by the toggle system (core/toggles.lua)
    -- vim.g.should_format() checks buffer-local override first, then global flag
    format_on_save = function(_bufnr)
      if not vim.g.should_format or not vim.g.should_format() then
        return nil
      end
      return { timeout_ms = 500, lsp_fallback = true }
    end,
  })
end)
if not ok then
  vim.notify("conform setup failed: " .. tostring(err), vim.log.levels.WARN)
end

-- Format keymap (cf = "code format", avoids collision with <leader>f Find group)
vim.keymap.set("n", "<leader>cf", function()
	require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "Format buffer" })
