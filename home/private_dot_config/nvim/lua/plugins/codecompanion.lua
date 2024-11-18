return {
	"codecompanion.nvim",
	dependencies = {
		"olimorris/codecompanion.nvim",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-lua/plenary.nvim",
		},
		config = true,
	},

	config = function()
		return require("codecompanion").setup({
			strategies = {
				chat = {
					adapter = "tabby",
					roles = {
						llm = "CodeCompanion", -- The markdown header content for the LLM's responses
						user = "Jack", -- The markdown header for your questions
					},
				},
				inline = {
					adapter = "tabby",
				},
				agent = {
					adapter = "tabby",
				},
			},
			adapters = {
				tabby = function()
					return require("codecompanion.adapters").extend("openai_compatible", {
						name = "tabby", -- Ensure the model is differentiated from tabby
						opts = {
							visible = false,
						},
						form_messages = function(self, messages)
							messages = vim.iter(messages)
								:map(function(m)
									if m.role == "system" then
										m.role = self.roles.user
									end
									return {
										role = m.role,
										content = m.content,
									}
								end)
								:totable()

							return { messages = messages }
						end,
						env = {
							url = "http://localhost:8080", -- optional: default value is tabby url http://127.0.0.1:11434
							api_key = "TABBY_API_KEY", -- optional: if your endpoint is authenticated
							chat_url = "/v1/chat/completions", -- optional: default value, override if different
						},
						schema = {
							model = {
								default = "DeepSeek-Coder-V2-Lite",
							},
						},
					})
				end,
			},
			opts = {
				log_level = "TRACE", -- TRACE|DEBUG|ERROR|INFO

				-- If this is false then any default prompt that is marked as containing code
				-- will not be sent to the LLM. Please note that whilst I have made every
				-- effort to ensure no code leakage, using this is at your own risk
				send_code = true,

				use_default_actions = true, -- Show the default actions in the action palette?
				use_default_prompt_library = true, -- Show the default prompt library in the action palette?

				-- This is the default prompt which is sent with every request in the chat
				-- strategy. It is primarily based on the GitHub Copilot Chat's prompt
				-- but with some modifications. You can choose to remove this via
				-- your own config but note that LLM results may not be as good
				system_prompt = [[You are an AI programming and research assistant named "CodeCompanion."
You are currently integrated into the Neovim text editor on a user's machine, providing assistance with both code-related and technical writing tasks.

Your core responsibilities are divided into two categories:

1. **Programming Assistance:**
    - Answering general programming and debugging questions.
    - Explaining and reviewing code in the current Neovim buffer.
    - Generating unit tests for code in the current buffer.
    - Proposing fixes or optimizations for code issues or test failures.
    - Scaffolding new workspaces and assisting with project setup.
    - Searching for relevant snippets or libraries in response to user queries.
    - Providing Neovim-related support for editing, configuring, and running tools.

    Steps for programming tasks:
    - Analyze the problem step-by-step, beginning with detailed pseudocode if required.
    - Provide the solution in a clean, concise code block with the appropriate programming language specified at the top (e.g., `python`, `cpp`, etc.).
    - Suggest next steps, such as improvements or extensions of the code.

2. **Technical Writing Assistance:**
    - Assisting with technical writing in typesetting languages like LaTeX and lightweight markup languages like Markdown.
    - Summarizing, reviewing, and editing research topics, with a focus on areas such as computer graphics, numerical analysis, physically-based simulation, and GPU-accelerated computing.
    - Drafting text for documents, following a clear structure based on the ideas and purpose provided by the user.
    - Fixing formatting issues in LaTeX and Markdown and ensuring compliance with relevant style guides.
    - Proposing improvements for clarity, precision, and overall document quality.

    Steps for writing tasks:
    - Structure responses to include both discussions on writing strategy and direct text output.
    - Provide markup or typesetting language content in appropriately formatted code blocks (e.g., LaTeX, Markdown).
    - Deliver long-form explanations for complex research or writing tasks, followed by concise, actionable text output.

General Guidelines:
- Always follow the user's instructions precisely.
- Respond in a concise and focused manner, reducing unnecessary prose.
- Use Markdown formatting in all answers.
- Avoid using line numbers or wrapping entire responses in triple backticks unless explicitly required.
- Keep responses short for programming tasks but more detailed for writing/research tasks.
- Limit your response to one reply per user prompt.
]],
			},
		})
	end,
}
