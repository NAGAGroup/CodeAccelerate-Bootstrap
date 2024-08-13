-- return {
--     -- "tzachar/cmp-ai.nvim",
--     -- opts = {
--     --     max_lines = 100,
--     --     provider = 'Ollama',
--     --     provider_options = {model = "CodeOllamaLlama3.1-8B"},
--     --     notify = true,
--     --     notify_callback = function(msg) vim.notify(msg) end,
--     --     run_on_every_keystroke = true,
--     --     ignored_file_types = {
--     --         -- default is not to ignore
--     --         -- uncomment to ignore in lua:
--     --         -- lua = true
--     --     }
--     -- }
-- } 
return {
    -- "hrsh7th/nvim-cmp",
    -- opts = function(_, opts)
    --     table.insert(opts.sources, 1, {name = "cmp_ai"})
    --     -- you need to take a look at the nvchad's original configuration of nvim-cmp to
    --     -- ensure you are using the correct location to insert "cmp_ai"
    -- end,
    -- dependencies = {
    --     "hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-buffer", "hrsh7th/cmp-path",
    --     'tzachar/cmp-ai'
    -- }
}

