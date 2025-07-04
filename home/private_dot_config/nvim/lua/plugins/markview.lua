return {
  -- Markdown Preview integration
  {
    "OXY2DEV/markview.nvim",
    ft = { "markdown", "quarto", "rmd", "codecompanion" },
    cmd = { "MarkviewOpen", "MarkviewToggle" },
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "nvim-treesitter/nvim-treesitter",
    },
    keys = {
      { "<leader>mp", "<cmd>MarkviewToggle<CR>", desc = "Toggle Markdown Preview" },
    },
    opts = {
      ft = { "markdown", "quarto", "rmd", "codecompanion" },
      preview = {
        filetypes = { "markdown", "quarto", "rmd", "codecompanion" },
        buf_ignore = {},
      },
    },
    config = function(_, opts)
      require("markview").setup(opts)
      
      -- Ensure treesitter has LaTeX grammar for math rendering
      local ts_config = require("nvim-treesitter.configs")
      local current_config = ts_config.get_module("ensure_installed") or {}
      if type(current_config) == "table" then
        if not vim.tbl_contains(current_config, "latex") then
          table.insert(current_config, "latex")
          ts_config.setup({ ensure_installed = current_config })
        end
      end
    end,
  },
}
