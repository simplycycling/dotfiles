return {
	"epwalsh/obsidian.nvim",
	version = "*",
	lazy = false,
	ft = "markdown",
	config = function()
		require("obsidian").setup({
			dir = "~/Documents/notes/",
		})
	end,

  vim.o.conceallevel = 2,

	dependencies = {
		"nvim-lua/plenary.nvim",
		"hrsh7th/nvim-cmp",
		"nvim-telescope/telescope.nvim",
		"nvim-treesitter/nvim-treesitter",
	},

}
