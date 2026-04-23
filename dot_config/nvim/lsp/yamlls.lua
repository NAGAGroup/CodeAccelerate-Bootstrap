return {
  settings = {
    yaml = {
      schemaStore = {
        enable = false,  -- MUST be false when using SchemaStore.nvim
        url    = '',
      },
      schemas  = require('schemastore').yaml.schemas(),
      validate = true,
      hover    = true,
      completion = true,
    },
  },
}
