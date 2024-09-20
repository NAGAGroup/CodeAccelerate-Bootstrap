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
                default = "deepseek-coder:6.7b",
              },
              num_ctx = {
                order = 3,
                mapping = "parameters.options",
                type = "number",
                optional = false,
                default = 8096,
                desc =
                "The maximum number of tokens that the language model can consider at once. This determines the size of the input context window, allowing the model to take into account longer text passages for generating responses. Adjusting this value can affect the model's performance and memory usage.",
                validate = function(n)
                  return n > 0, "Must be a positive number"
                end,
              }
            },
          })
        end,
      },
    })
  end
}
