return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        cmake = { "cmake-format" },
      },
    }
  },
  {
    "williamboman/mason.nvim",
    opts = { ensure_installed = { "cmakelang" }, },
  }
}
