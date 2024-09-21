return {
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        cmake = { "cmake-lint", bash = { "shellcheck" }, sh = { "shellcheck" } }
      },
    }
  },
  {
    "williamboman/mason.nvim",
    opts = { ensure_installed = { "shellcheck", "cmakelang" }, },
  }
}
