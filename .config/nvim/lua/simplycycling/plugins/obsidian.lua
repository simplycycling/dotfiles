return {
	"epwalsh/obsidian.nvim",
	version = "*",
	lazy = true,
	ft = "markdown",
	config = function()
		require("obsidian").setup({
			dir = "~/Documents/notes/",
		})
	end,

	dependencies = {
		"nvim-lua/plenary.nvim",
		"hrsh7th/nvim-cmp",
		"nvim-telescope/telescope.nvim",
		"nvim-treesitter/nvim-treesitter",
	},

	-- opts = {
	--	workspaces = {
	--		{
	--			name = "personal",
	--			path = "~/Documents/notes/",
	--		},
	--	},

	--	completion = {
	--		nvim_cmp = true,
	--		min_chars = 2,
	--	},
	--},
}
