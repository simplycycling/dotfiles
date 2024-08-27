return {
	"epwalsh/obsidian.nvim",
	version = "*",
	lazy = true,
	ft = "markdown",

	dependencies = {
		"nvim-lua/plenary.nvim",
		"hrsh7ja/nvim-cmp",
		"nvim-telescope/telescope.nvim",
		"nvim-treesitter/nvim-treesitter",
	},

	opts = {
		workspaces = {
			{
				name = "personal",
				path = "~/Documents/notes/",
			},
		},

		completion = {
			nvim_cmp = true,
			min_chars = 2,
		},
	},
}
