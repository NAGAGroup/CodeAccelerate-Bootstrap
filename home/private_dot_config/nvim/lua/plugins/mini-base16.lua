return {
	"echasnovski/mini.base16",
	version = false,
	opts = {
		-- Table with names from `base00` to `base0F` and values being strings of
		-- HEX colors with format "#RRGGBB". NOTE: this should be explicitly
		-- supplied in `setup()`.
		palette = {
			base00 = "#0f1419",
			base01 = "#131721",
			base02 = "#272d38",
			base03 = "#3e4b59",
			base04 = "#bfbdb6",
			base05 = "#e6e1cf",
			base06 = "#e6e1cf",
			base07 = "#f3f4f5",
			base08 = "#f07178",
			base09 = "#ff8f40",
			base0A = "#ffb454",
			base0B = "#b8cc52",
			base0C = "#95e6cb",
			base0D = "#59c2ff",
			base0E = "#d2a6ff",
			base0F = "#e6b673",
		},
		-- Whether to support cterm colors. Can be boolean, `nil` (same as
		-- `false`), or table with cterm colors. See `setup()` documentation for
		-- more information.
		use_cterm = true,

		-- Plugin integrations. Use `default = false` to disable all integrations.
		-- Also can be set per plugin (see |MiniBase16.config|).
		plugins = { default = true },
	},
}
