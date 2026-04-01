return {
	"epwalsh/obsidian.nvim",
	version = "*",
	lazy = false,
	ft = "markdown",
	config = function()
		require("obsidian").setup({
			workspaces = {
				{
					name = "notes",
					path = "~/Documents/notes/",
				},
			},
			notes_subdir = "Inbox",
			new_notes_location = "notes_subdir",
			templates = {
				folder = "templates",
			},
		})
		vim.o.conceallevel = 2
	end,

	dependencies = {
		"nvim-lua/plenary.nvim",
		"hrsh7th/nvim-cmp",
		"nvim-telescope/telescope.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
}
