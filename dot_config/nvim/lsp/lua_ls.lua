return {
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
      },
      workspace = {
        checkThirdParty = false,
        -- lazydev handles library paths via its lspconfig integration
      },
      telemetry = {
        enable = false,
      },
    },
  },
}
