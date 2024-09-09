return {
  "codecompanion.nvim",
  dependencies = {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-lua/plenary.nvim"
    },
    config = true
  },

  config = function()
    return require("codecompanion").setup({
      strategies = {
        chat = {
          adapter = "codellama",
          roles = {
            llm = "assistant", -- The markdown header content for the LLM's responses
            user = "user",     -- The markdown header for your questions
          },
        },
        inline = {
          adapter = "codellama"
        },
        agent = {
          adapter = "codellama",
        },
      },
      adapters = {
        codellama = function()
          return require("codecompanion.adapters").extend("ollama", {
            name = "codellama", -- Ensure the model is differentiated from Ollama
            schema = {
              model = {
                default = "codellama:7b",
              }
            },
          })
        end,
      },
    })
  end
}
