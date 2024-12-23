return {
	"nvzone/showkeys",
	cmd = "ShowkeysToggle",
	opts = {

		timeout = 3, -- in secs
		maxkeys = 10,
		show_count = true,
		excluded_modes = {}, -- example: {"i"}

		-- bottom-left, bottom-right, bottom-center, top-left, top-right, top-center
		position = "top-center",
	},
}
