return {
  filetypes = {
    'javascript',
    'javascriptreact',
    'typescript',
    'typescriptreact',
  },
  settings = {
    vtsls = {
      experimental = {
        completion = {
          enableServerSideFuzzyMatch = true,
        },
      },
      typescript = {
        inlayHints = {
          parameterNames            = { enabled = 'literals' },
          parameterTypes            = { enabled = true },
          variableTypes             = { enabled = false },
          propertyDeclarationTypes  = { enabled = true },
          functionLikeReturnTypes   = { enabled = true },
        },
      },
      javascript = {
        inlayHints = {
          parameterNames            = { enabled = 'literals' },
          parameterTypes            = { enabled = true },
          variableTypes             = { enabled = false },
          propertyDeclarationTypes  = { enabled = true },
          functionLikeReturnTypes   = { enabled = true },
        },
      },
    },
  },
}
