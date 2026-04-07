-- Helper for GitHub URLs
local gh = function(x)
	return "https://github.com/" .. x
end

-- Wraps a setup block so a missing plugin warns but doesn't abort the file
local safe = function(fn)
	local ok, err = pcall(fn)
	if not ok then
		vim.schedule(function()
			vim.notify("[pack.lua] " .. tostring(err), vim.log.levels.WARN)
		end)
	end
end

-- Build hooks: run make/update steps after install or update
vim.api.nvim_create_autocmd("PackChanged", {
	callback = function(ev)
		local name = ev.data.spec.name
		local kind = ev.data.kind
		local path = ev.data.path
		if kind ~= "install" and kind ~= "update" then
			return
		end

		if name == "telescope-fzf-native.nvim" then
			vim.system({ "make" }, { cwd = path }):wait()
		elseif name == "LuaSnip" then
			vim.system({ "make", "install_jsregexp" }, { cwd = path }):wait()
		elseif name == "nvim-treesitter" then
			if ev.data.active then
				vim.cmd("TSUpdate")
			end
		end
	end,
})

-- ── Plugins ──────────────────────────────────────────────────────────────────

-- Lua utilities (required by many plugins)
vim.pack.add({ gh("nvim-lua/plenary.nvim") })

-- Tmux/split navigation
vim.pack.add({ gh("christoomey/vim-tmux-navigator") })

-- ── UI Layer ──────────────────────────────────────────────────────────────────

-- Icons (shared dependency for lualine, bufferline, nvim-tree, alpha)
vim.pack.add({ gh("nvim-tree/nvim-web-devicons") })

-- Colorscheme (load first so it's available for everything below)
vim.pack.add({ gh("folke/tokyonight.nvim") })
safe(function()
	local bg = "#011628"
	local bg_dark = "#011423"
	local bg_highlight = "#143652"
	local bg_search = "#0A64AC"
	local bg_visual = "#275378"
	local fg = "#CBE0F0"
	local fg_dark = "#B4D0E9"
	local fg_gutter = "#627E97"
	local border = "#547998"

	require("tokyonight").setup({
		transparent = true,
		styles = {
			"night",
			sidebars = "transparent",
			floats = "transparent",
		},
		on_colors = function(colors)
			colors.bg = bg
			colors.bg_dark = bg_dark
			colors.bg_float = bg_dark
			colors.bg_highlight = bg_highlight
			colors.bg_popup = bg_dark
			colors.bg_search = bg_search
			colors.bg_sidebar = bg_dark
			colors.bg_statusline = bg_dark
			colors.bg_visual = bg_visual
			colors.border = border
			colors.fg = fg
			colors.fg_dark = fg_dark
			colors.fg_float = fg
			colors.fg_gutter = fg_gutter
			colors.fg_sidebar = fg_dark
		end,
	})
	vim.cmd([[colorscheme tokyonight]])
end)

-- Statusline
vim.pack.add({ gh("nvim-lualine/lualine.nvim") })
safe(function()
	local colors = {
		blue = "#65D1FF",
		green = "#3EFFDC",
		violet = "#FF61EF",
		yellow = "#FFDA7B",
		red = "#FF4A4A",
		fg = "#c3ccdc",
		bg = "#112638",
		inactive_bg = "#2c3043",
	}

	local my_lualine_theme = {
		normal = {
			a = { bg = colors.blue, fg = colors.bg, gui = "bold" },
			b = { bg = colors.bg, fg = colors.fg },
			c = { bg = colors.bg, fg = colors.fg },
		},
		insert = {
			a = { bg = colors.green, fg = colors.bg, gui = "bold" },
			b = { bg = colors.bg, fg = colors.fg },
			c = { bg = colors.bg, fg = colors.fg },
		},
		visual = {
			a = { bg = colors.violet, fg = colors.bg, gui = "bold" },
			b = { bg = colors.bg, fg = colors.fg },
			c = { bg = colors.bg, fg = colors.fg },
		},
		command = {
			a = { bg = colors.yellow, fg = colors.bg, gui = "bold" },
			b = { bg = colors.bg, fg = colors.fg },
			c = { bg = colors.bg, fg = colors.fg },
		},
		replace = {
			a = { bg = colors.red, fg = colors.bg, gui = "bold" },
			b = { bg = colors.bg, fg = colors.fg },
			c = { bg = colors.bg, fg = colors.fg },
		},
		inactive = {
			a = { bg = colors.inactive_bg, fg = colors.semilightgray, gui = "bold" },
			b = { bg = colors.inactive_bg, fg = colors.semilightgray },
			c = { bg = colors.inactive_bg, fg = colors.semilightgray },
		},
	}

	require("lualine").setup({
		options = { theme = my_lualine_theme },
		sections = {
			lualine_x = {
				{ "encoding" },
				{ "fileformat" },
				{ "filetype" },
			},
		},
	})
end)

-- Bufferline (tabs)
vim.pack.add({ gh("akinsho/bufferline.nvim") })
safe(function()
	require("bufferline").setup({
		options = {
			mode = "tabs",
			separator_style = "slant",
		},
	})
end)

-- Indent guides
vim.pack.add({ gh("lukas-reineke/indent-blankline.nvim") })
safe(function()
	require("ibl").setup({ indent = { char = "┊" } })
end)

-- Dashboard / start screen
vim.pack.add({ gh("goolord/alpha-nvim") })
safe(function()
	local alpha = require("alpha")
	local dashboard = require("alpha.themes.dashboard")

	dashboard.section.header.val = {
		"                                                     ",
		"  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ",
		"  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ",
		"  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ",
		"  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ",
		"  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ",
		"  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ",
		"                                                     ",
	}

	dashboard.section.buttons.val = {
		dashboard.button("e", "  > New File", "<cmd>ene<CR>"),
		dashboard.button("SPC ee", "  > Toggle file explorer", "<cmd>NvimTreeToggle<CR>"),
		dashboard.button("SPC ff", "󰱼 > Find File", "<cmd>Telescope find_files<CR>"),
		dashboard.button("SPC fs", "  > Find Word", "<cmd>Telescope live_grep<CR>"),
		dashboard.button("SPC wr", "󰁯  > Restore Session For Current Directory", "<cmd>SessionRestore<CR>"),
		dashboard.button("q", " > Quit NVIM", "<cmd>qa<CR>"),
	}

	alpha.setup(dashboard.opts)
	vim.cmd([[autocmd FileType alpha setlocal nofoldenable]])
end)

-- ── Editor Utilities ──────────────────────────────────────────────────────────

-- Surround motions (ys, cs, ds)
vim.pack.add({ gh("kylechui/nvim-surround") })
safe(function()
	require("nvim-surround").setup()
end)

-- Auto-close pairs
vim.pack.add({ gh("windwp/nvim-autopairs") })
safe(function()
	require("nvim-autopairs").setup({
		check_ts = true,
		ts_config = {
			lua = { "string" },
			javascript = { "template_string" },
			java = false,
		},
	})
end)
-- Wire autopairs into cmp once cmp is available (cmp added in completion group)
vim.api.nvim_create_autocmd("VimEnter", {
	once = true,
	callback = function()
		local ok, cmp = pcall(require, "cmp")
		if not ok then
			return
		end
		local cmp_autopairs = require("nvim-autopairs.completion.cmp")
		cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
	end,
})

-- Substitute operator (s, ss, S)
vim.pack.add({ gh("gbprod/substitute.nvim") })
safe(function()
	local substitute = require("substitute")
	substitute.setup()
	vim.keymap.set("n", "s", substitute.operator, { desc = "Substitute with motion" })
	vim.keymap.set("n", "ss", substitute.line, { desc = "Substitute line" })
	vim.keymap.set("n", "S", substitute.eol, { desc = "Substitute to end of line" })
	vim.keymap.set("x", "s", substitute.visual, { desc = "Substitute in visual mode" })
end)

-- Commenting (with treesitter-aware context)
vim.pack.add({ gh("JoosepAlviste/nvim-ts-context-commentstring") })
vim.pack.add({ gh("numToStr/Comment.nvim") })
safe(function()
	require("ts_context_commentstring").setup({ enable_autocmd = false })
	require("Comment").setup({
		pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
	})
end)

-- Keybinding hints
vim.o.timeout = true
vim.o.timeoutlen = 500
vim.pack.add({ gh("folke/which-key.nvim") })
safe(function()
	require("which-key").setup()
end)

-- Better vim.ui.select / vim.ui.input
vim.pack.add({ gh("stevearc/dressing.nvim") })
safe(function()
	require("dressing").setup()
end)

-- Maximize/restore splits
vim.pack.add({ gh("szw/vim-maximizer") })
vim.keymap.set("n", "<leader>sm", "<cmd>MaximizerToggle<CR>", { desc = "Maximize/minimize a split" })

-- ── File / Search ─────────────────────────────────────────────────────────────

-- File explorer
vim.pack.add({ gh("nvim-tree/nvim-tree.lua") })
safe(function()
	vim.g.loaded_netrw = 1
	vim.g.loaded_netrwPlugin = 1

	require("nvim-tree").setup({
		view = {
			width = 35,
			relativenumber = true,
		},
		renderer = {
			indent_markers = { enable = true },
			icons = {
				glyphs = {
					folder = {
						arrow_closed = "",
						arrow_open = "",
					},
				},
			},
		},
		actions = {
			open_file = {
				window_picker = { enable = false },
			},
		},
		filters = { custom = { ".DS_Store" } },
		git = { ignore = false },
	})

	local keymap = vim.keymap
	keymap.set("n", "<leader>ee", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
	keymap.set("n", "<leader>ef", "<cmd>NvimTreeFindFileToggle<CR>", { desc = "Toggle file explorer on current file" })
	keymap.set("n", "<leader>ec", "<cmd>NvimTreeCollapse<CR>", { desc = "Collapse file explorer" })
	keymap.set("n", "<leader>er", "<cmd>NvimTreeRefresh<CR>", { desc = "Refresh file explorer" })
end)

-- Fuzzy finder (fzf-native has a make build step, handled by PackChanged hook)
vim.pack.add({
	gh("nvim-telescope/telescope.nvim"),
	{ src = gh("nvim-telescope/telescope-fzf-native.nvim"), version = "main" },
})
safe(function()
	local telescope = require("telescope")
	local actions = require("telescope.actions")

	telescope.setup({
		defaults = {
			path_display = { "smart" },
			mappings = {
				i = {
					["<C-k>"] = actions.move_selection_previous,
					["<C-j>"] = actions.move_selection_next,
					["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
				},
			},
		},
	})

	local fzf_lib = vim.fn.stdpath("data") .. "/site/pack/core/opt/telescope-fzf-native.nvim/build/libfzf.so"
	if vim.uv.fs_stat(fzf_lib) then
		telescope.load_extension("fzf")
	end

	local keymap = vim.keymap
	keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Fuzzy find files in cwd" })
	keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Fuzzy find recent files" })
	keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>", { desc = "Find string in cwd" })
	keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", { desc = "Find string under cursor in cwd" })
	keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "Find todos" })
end)

-- Todo comment highlights and navigation
vim.pack.add({ gh("folke/todo-comments.nvim") })
safe(function()
	local todo_comments = require("todo-comments")
	vim.keymap.set("n", "]t", function()
		todo_comments.jump_next()
	end, { desc = "Next todo comment" })
	vim.keymap.set("n", "[t", function()
		todo_comments.jump_prev()
	end, { desc = "Previous todo comment" })
	todo_comments.setup()
end)

-- ── Git ───────────────────────────────────────────────────────────────────────

-- Git signs in the gutter
vim.pack.add({ gh("lewis6991/gitsigns.nvim") })
safe(function()
	require("gitsigns").setup({
		on_attach = function(bufnr)
			local gs = package.loaded.gitsigns

			local function map(mode, l, r, desc)
				vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
			end

			map("n", "]h", gs.next_hunk, "Next Hunk")
			map("n", "[h", gs.prev_hunk, "Prev Hunk")

			map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
			map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
			map("v", "<leader>hs", function()
				gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
			end, "Stage hunk")
			map("v", "<leader>hr", function()
				gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
			end, "Reset hunk")

			map("n", "<leader>hS", gs.stage_buffer, "Stage buffer")
			map("n", "<leader>hR", gs.reset_buffer, "Reset buffer")
			map("n", "<leader>hu", gs.undo_stage_hunk, "Undo stage hunk")
			map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")

			map("n", "<leader>hb", function()
				gs.blame_line({ full = true })
			end, "Blame line")
			map("n", "<leader>hB", gs.toggle_current_line_blame, "Toggle line blame")

			map("n", "<leader>hd", gs.diffthis, "Diff this")
			map("n", "<leader>hD", function()
				gs.diffthis("~")
			end, "Diff this ~")

			map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Gitsigns select hunk")
		end,
	})
end)

-- Lazygit integration
vim.pack.add({ gh("kdheepak/lazygit.nvim") })
vim.keymap.set("n", "<leader>lg", "<cmd>LazyGit<cr>", { desc = "Open lazy git" })

-- ── Sessions ──────────────────────────────────────────────────────────────────

vim.pack.add({ gh("rmagatti/auto-session") })
safe(function()
	require("auto-session").setup({
		auto_restore_enabled = false,
		auto_session_suppress_dirs = { "~/", "~/src", "~/Downloads", "~/Documents", "~/Desktop" },
	})

	vim.keymap.set("n", "<leader>wr", "<cmd>SessionRestore<CR>", { desc = "Restore session for cwd" })
	vim.keymap.set("n", "<leader>ws", "<cmd>SessionSave<CR>", { desc = "Save session for auto session root dir" })
end)

-- ── Treesitter ────────────────────────────────────────────────────────────────

-- nvim-ts-autotag must be added before treesitter so it's available during setup
vim.pack.add({ gh("windwp/nvim-ts-autotag") })

-- TSUpdate build step is handled by the PackChanged hook at the top of this file
vim.pack.add({ gh("nvim-treesitter/nvim-treesitter") })
safe(function()
	-- New nvim-treesitter API: setup() only accepts install_dir
	require("nvim-treesitter").setup()

	-- Enable treesitter highlighting globally (replaces highlight = { enable = true })
	vim.api.nvim_create_autocmd("FileType", {
		callback = function(ev)
			pcall(vim.treesitter.start, ev.buf)
		end,
	})

	-- Install parsers
	require("nvim-treesitter").install({
		"python",
		"json",
		"yaml",
		"html",
		"css",
		"markdown",
		"markdown_inline",
		"bash",
		"lua",
		"vim",
		"dockerfile",
		"gitignore",
		"vimdoc",
		"ruby",
	})
end)

-- Diagnostics, quickfix, and todo list panel
vim.pack.add({ gh("folke/trouble.nvim") })
safe(function()
	require("trouble").setup({ focus = true })

	local keymap = vim.keymap
	keymap.set(
		"n",
		"<leader>xw",
		"<cmd>Trouble diagnostics toggle<CR>",
		{ desc = "Open trouble workspace diagnostics" }
	)
	keymap.set(
		"n",
		"<leader>xd",
		"<cmd>Trouble diagnostics toggle filter.buf=0<CR>",
		{ desc = "Open trouble document diagnostics" }
	)
	keymap.set("n", "<leader>xq", "<cmd>Trouble quickfix toggle<CR>", { desc = "Open trouble quickfix list" })
	keymap.set("n", "<leader>xl", "<cmd>Trouble loclist toggle<CR>", { desc = "Open trouble location list" })
	keymap.set("n", "<leader>xt", "<cmd>Trouble todo toggle<CR>", { desc = "Open todos in trouble" })
end)

-- ── Completion ────────────────────────────────────────────────────────────────

-- LuaSnip build step is handled by the PackChanged hook at the top of this file
vim.pack.add({
	gh("hrsh7th/nvim-cmp"),
	gh("hrsh7th/cmp-buffer"),
	gh("hrsh7th/cmp-path"),
	gh("hrsh7th/cmp-nvim-lsp"),
	{ src = gh("L3MON4D3/LuaSnip"), version = vim.version.range(">=2.0.0, <3.0.0") },
	gh("saadparwaiz1/cmp_luasnip"),
	gh("rafamadriz/friendly-snippets"),
	gh("onsails/lspkind.nvim"),
})
safe(function()
	local cmp = require("cmp")
	local luasnip = require("luasnip")
	local lspkind = require("lspkind")

	require("luasnip.loaders.from_vscode").lazy_load()

	cmp.setup({
		completion = {
			completeopt = "menu,menuone,preview,noselect",
		},
		snippet = {
			expand = function(args)
				luasnip.lsp_expand(args.body)
			end,
		},
		mapping = cmp.mapping.preset.insert({
			["<C-k>"] = cmp.mapping.select_prev_item(),
			["<C-j>"] = cmp.mapping.select_next_item(),
			["<C-b>"] = cmp.mapping.scroll_docs(-4),
			["<C-f>"] = cmp.mapping.scroll_docs(4),
			["<C-Space>"] = cmp.mapping.complete(),
			["<C-e>"] = cmp.mapping.abort(),
			["<CR>"] = cmp.mapping.confirm({ select = false }),
		}),
		sources = cmp.config.sources({
			{ name = "nvim_lsp" },
			{ name = "luasnip" },
			{ name = "buffer" },
			{ name = "path" },
		}),
		formatting = {
			format = lspkind.cmp_format({
				maxwidth = 50,
				ellipsis_char = "...",
			}),
		},
	})
end)

-- ── LSP ───────────────────────────────────────────────────────────────────────

-- Mason (LSP server / tool installer) must be set up before lspconfig
vim.pack.add({
	gh("williamboman/mason.nvim"),
	gh("williamboman/mason-lspconfig.nvim"),
	gh("WhoIsSethDaniel/mason-tool-installer.nvim"),
})
safe(function()
	require("mason").setup({
		ui = {
			icons = {
				package_installed = "✓",
				package_pending = "➜",
				package_uninstalled = "✗",
			},
		},
	})

	require("mason-lspconfig").setup({
		ensure_installed = {
			"html",
			"cssls",
			"tailwindcss",
			"lua_ls",
			"graphql",
			"emmet_ls",
			"prismals",
			"pyright",
		},
		automatic_enable = true,
	})

	require("mason-tool-installer").setup({
		ensure_installed = {
			"prettier",
			"stylua",
			"isort",
			"black",
			"pylint",
			"eslint_d",
		},
	})
end)

-- LSP configuration
vim.pack.add({
	gh("neovim/nvim-lspconfig"),
	gh("antosha417/nvim-lsp-file-operations"),
	gh("folke/neodev.nvim"),
})
safe(function()
	require("neodev").setup()
	require("lsp-file-operations").setup()

	local capabilities = require("cmp_nvim_lsp").default_capabilities()

	vim.api.nvim_create_autocmd("LspAttach", {
		group = vim.api.nvim_create_augroup("UserLspConfig", {}),
		callback = function(ev)
			local opts = { buffer = ev.buf, silent = true }

			opts.desc = "Show LSP references"
			vim.keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)

			opts.desc = "Go to declaration"
			vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

			opts.desc = "Show LSP definitions"
			vim.keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)

			opts.desc = "Show LSP implementations"
			vim.keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)

			opts.desc = "Show LSP type definitions"
			vim.keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)

			opts.desc = "See available code actions"
			vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

			opts.desc = "Smart rename"
			vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

			opts.desc = "Show buffer diagnostics"
			vim.keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)

			opts.desc = "Show line diagnostics"
			vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)

			opts.desc = "Go to previous diagnostic"
			vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)

			opts.desc = "Go to next diagnostic"
			vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

			opts.desc = "Show documentation for what is under cursor"
			vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

			opts.desc = "Restart LSP"
			vim.keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)
		end,
	})

	local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
	for type, icon in pairs(signs) do
		local hl = "DiagnosticSign" .. type
		vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
	end

	local default_config = { capabilities = capabilities }

	vim.lsp.config(
		"svelte",
		vim.tbl_deep_extend("force", default_config, {
			on_attach = function(client, bufnr)
				vim.api.nvim_create_autocmd("BufWritePost", {
					pattern = { "*.js", "*.ts" },
					callback = function(ctx)
						client.notify("$/onDidChangeTsOrJsFile", { uri = ctx.match })
					end,
				})
			end,
		})
	)

	vim.lsp.config(
		"graphql",
		vim.tbl_deep_extend("force", default_config, {
			filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" },
		})
	)

	vim.lsp.config(
		"emmet_ls",
		vim.tbl_deep_extend("force", default_config, {
			filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less", "svelte" },
		})
	)

	vim.lsp.config(
		"lua_ls",
		vim.tbl_deep_extend("force", default_config, {
			settings = {
				Lua = {
					diagnostics = { globals = { "vim" } },
					completion = { callSnippet = "Replace" },
				},
			},
		})
	)
end)

-- Formatting
vim.pack.add({ gh("stevearc/conform.nvim") })
safe(function()
	require("conform").setup({
		formatters_by_ft = {
			javascript = { "prettier" },
			typescript = { "prettier" },
			javascriptreact = { "prettier" },
			typescriptreact = { "prettier" },
			svelte = { "prettier" },
			css = { "prettier" },
			html = { "prettier" },
			json = { "prettier" },
			yaml = { "prettier" },
			graphql = { "prettier" },
			liquid = { "prettier" },
			lua = { "stylua" },
			python = { "isort", "black" },
		},
		format_on_save = {
			lsp_fallback = true,
			async = false,
			timeout_ms = 1000,
		},
	})

	vim.keymap.set({ "n", "v" }, "<leader>mp", function()
		require("conform").format({ lsp_fallback = true, async = false, timeout_ms = 1000 })
	end, { desc = "Format file or range (in visual mode)" })
end)

-- Linting
vim.pack.add({ gh("mfussenegger/nvim-lint") })
safe(function()
	local lint = require("lint")

	lint.linters_by_ft = {
		javascript = { "eslint_d" },
		typescript = { "eslint_d" },
		javascriptreact = { "eslint_d" },
		typescriptreact = { "eslint_d" },
		svelte = { "eslint_d" },
		python = { "pylint" },
	}

	local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
	vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
		group = lint_augroup,
		callback = function()
			lint.try_lint()
		end,
	})

	vim.keymap.set("n", "<leader>l", function()
		lint.try_lint()
	end, { desc = "Trigger linting for current file" })
end)

-- ── Obsidian ──────────────────────────────────────────────────────────────────

vim.pack.add({ gh("epwalsh/obsidian.nvim") })
safe(function()
	require("obsidian").setup({
		workspaces = {
			{
				name = "notes",
				path = "~/Documents/simplycycling/",
			},
		},
		notes_subdir = "Inbox",
		new_notes_location = "notes_subdir",
		templates = {
			folder = "templates",
		},
		disable_frontmatter = true,
		mappings = {
			["gf"] = {
				action = function()
					return require("obsidian").util.gf_passthrough()
				end,
				opts = { noremap = false, expr = true, buffer = true },
			},
		},
		ui = { enable = false },
	})
end)

-- ── Markdown Renderer ───────────────────────────────────────────────────────
vim.pack.add({
	"https://github.com/nvim-treesitter/nvim-treesitter",
	"https://github.com/nvim-mini/mini.nvim", -- if you use the mini.nvim suite
	-- 'https://github.com/nvim-mini/mini.icons',        -- if you use standalone mini plugins
	-- 'https://github.com/nvim-tree/nvim-web-devicons', -- if you prefer nvim-web-devicons
	"https://github.com/MeanderingProgrammer/render-markdown.nvim",
})
require("render-markdown").setup({
	-- Whether markdown should be rendered by default.
	enabled = true,
	-- Vim modes that will show a rendered view of the markdown file, :h mode(), for all enabled
	-- components. Individual components can be enabled for other modes. Remaining modes will be
	-- unaffected by this plugin.
	render_modes = { "n", "c", "t" },
	-- Milliseconds that must pass before updating marks, updates occur.
	-- within the context of the visible window, not the entire buffer.
	debounce = 100,
	-- Pre configured settings that will attempt to mimic various target user experiences.
	-- User provided settings will take precedence.
	-- | obsidian | mimic Obsidian UI                                          |
	-- | lazy     | will attempt to stay up to date with LazyVim configuration |
	-- | none     | does nothing                                               |
	preset = "none",
	-- The level of logs to write to file: vim.fn.stdpath('state') .. '/render-markdown.log'.
	-- Only intended to be used for plugin development / debugging.
	log_level = "error",
	-- Print runtime of main update method.
	-- Only intended to be used for plugin development / debugging.
	log_runtime = false,
	-- Filetypes this plugin will run on.
	file_types = { "markdown" },
	-- Maximum file size (in MB) that this plugin will attempt to render.
	-- File larger than this will effectively be ignored.
	max_file_size = 10.0,
	-- Takes buffer as input, if it returns true this plugin will not attach to the buffer.
	ignore = function()
		return false
	end,
	-- Whether markdown should be rendered when nested inside markdown, i.e. markdown code block
	-- inside markdown file.
	nested = true,
	-- Additional events that will trigger this plugin's render loop.
	change_events = {},
	-- Whether the treesitter highlighter should be restarted after this plugin attaches to its
	-- first buffer for the first time. May be necessary if this plugin is lazy loaded to clear
	-- highlights that have been dynamically disabled.
	restart_highlighter = false,
	injections = {
		-- Out of the box language injections for known filetypes that allow markdown to be interpreted
		-- in specified locations, see :h treesitter-language-injections.
		-- Set enabled to false in order to disable.

		gitcommit = {
			enabled = true,
			query = [[
                ((message) @injection.content
                    (#set! injection.combined)
                    (#set! injection.include-children)
                    (#set! injection.language "markdown"))
            ]],
		},
	},
	patterns = {
		-- Highlight patterns to disable for filetypes, i.e. lines concealed around code blocks

		markdown = {
			disable = true,
			directives = {
				{ id = 17, name = "conceal_lines" },
				{ id = 18, name = "conceal_lines" },
			},
		},
	},
	anti_conceal = {
		-- This enables hiding added text on the line the cursor is on.
		enabled = true,
		-- Modes to disable anti conceal feature.
		disabled_modes = false,
		-- Number of lines above cursor to show.
		above = 0,
		-- Number of lines below cursor to show.
		below = 0,
		-- Which elements to always show, ignoring anti conceal behavior. Values can either be
		-- booleans to fix the behavior or string lists representing modes where anti conceal
		-- behavior will be ignored. Valid values are:
		--   bullet
		--   callout
		--   check_icon, check_scope
		--   code_background, code_border, code_language
		--   dash
		--   head_background, head_border, head_icon
		--   indent
		--   latex
		--   link
		--   quote
		--   sign
		--   table_border
		--   virtual_lines
		ignore = {
			code_background = true,
			indent = true,
			sign = true,
			virtual_lines = true,
		},
	},
	padding = {
		-- Highlight to use when adding whitespace, should match background.
		highlight = "Normal",
	},
	latex = {
		-- Turn on / off latex rendering.
		enabled = true,
		-- Additional modes to render latex.
		render_modes = false,
		-- Executable used to convert latex formula to rendered unicode.
		-- If a list is provided the commands run in order until the first success.
		converter = { "utftex", "latex2text" },
		-- Highlight for latex blocks.
		highlight = "RenderMarkdownMath",
		-- Determines where latex formula is rendered relative to block.
		-- | above  | above latex block                               |
		-- | below  | below latex block                               |
		-- | center | centered with latex block (must be single line) |
		position = "center",
		-- Number of empty lines above latex blocks.
		top_pad = 0,
		-- Number of empty lines below latex blocks.
		bottom_pad = 0,
	},
	on = {
		-- Called when plugin initially attaches to a buffer.
		attach = function() end,
		-- Called before adding marks to the buffer for the first time.
		initial = function() end,
		-- Called after plugin renders a buffer.
		render = function() end,
		-- Called after plugin clears a buffer.
		clear = function() end,
	},
	completions = {
		-- Settings for blink.cmp completions source
		blink = { enabled = false },
		-- Settings for coq_nvim completions source
		coq = { enabled = false },
		-- Settings for in-process language server completions
		lsp = { enabled = false },
		filter = {
			callout = function()
				-- example to exclude obsidian callouts
				-- return value.category ~= 'obsidian'
				return true
			end,
			checkbox = function()
				return true
			end,
		},
	},
	heading = {
		-- Useful context to have when evaluating values.
		-- | level    | the number of '#' in the heading marker         |
		-- | sections | for each level how deeply nested the heading is |

		-- Turn on / off heading icon & background rendering.
		enabled = true,
		-- Additional modes to render headings.
		render_modes = false,
		-- Turn on / off atx heading rendering.
		atx = true,
		-- Turn on / off setext heading rendering.
		setext = true,
		-- Turn on / off sign column related rendering.
		sign = true,
		-- Replaces '#+' of 'atx_h._marker'.
		-- Output is evaluated depending on the type.
		-- | function | `value(context)`              |
		-- | string[] | `cycle(value, context.level)` |
		icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
		-- Determines how icons fill the available space.
		-- | eol     | '#'s are concealed and icon is placed at right most column   |
		-- | right   | '#'s are concealed and icon is appended to right side        |
		-- | inline  | '#'s are concealed and icon is inlined on left side          |
		-- | overlay | icon is left padded with spaces and overlayed hiding all '#' |
		position = "overlay",
		-- Added to the sign column if enabled.
		-- Output is evaluated by `cycle(value, context.level)`.
		signs = { "󰫎 " },
		-- Width of the heading background.
		-- | block | width of the heading text |
		-- | full  | full width of the window  |
		-- Can also be a list of the above values evaluated by `clamp(value, context.level)`.
		width = "full",
		-- Amount of margin to add to the left of headings.
		-- Margin available space is computed after accounting for padding.
		-- If a float < 1 is provided it is treated as a percentage of available window space.
		-- Can also be a list of numbers evaluated by `clamp(value, context.level)`.
		left_margin = 0,
		-- Amount of padding to add to the left of headings.
		-- Output is evaluated using the same logic as 'left_margin'.
		left_pad = 0,
		-- Amount of padding to add to the right of headings when width is 'block'.
		-- Output is evaluated using the same logic as 'left_margin'.
		right_pad = 0,
		-- Minimum width to use for headings when width is 'block'.
		-- Can also be a list of integers evaluated by `clamp(value, context.level)`.
		min_width = 0,
		-- Determines if a border is added above and below headings.
		-- Can also be a list of booleans evaluated by `clamp(value, context.level)`.
		border = false,
		-- Always use virtual lines for heading borders instead of attempting to use empty lines.
		border_virtual = false,
		-- Highlight the start of the border using the foreground highlight.
		border_prefix = false,
		-- Used above heading for border.
		above = "▄",
		-- Used below heading for border.
		below = "▀",
		-- Highlight for the heading icon and extends through the entire line.
		-- Output is evaluated by `clamp(value, context.level)`.
		backgrounds = {
			"RenderMarkdownH1Bg",
			"RenderMarkdownH2Bg",
			"RenderMarkdownH3Bg",
			"RenderMarkdownH4Bg",
			"RenderMarkdownH5Bg",
			"RenderMarkdownH6Bg",
		},
		-- Highlight for the heading and sign icons.
		-- Output is evaluated using the same logic as 'backgrounds'.
		foregrounds = {
			"RenderMarkdownH1",
			"RenderMarkdownH2",
			"RenderMarkdownH3",
			"RenderMarkdownH4",
			"RenderMarkdownH5",
			"RenderMarkdownH6",
		},
		-- Define custom heading patterns which allow you to override various properties based on
		-- the contents of a heading.
		-- The key is for healthcheck and to allow users to change its values, value type below.
		-- | pattern    | matched against the heading text @see :h lua-patterns |
		-- | icon       | optional override for the icon                        |
		-- | background | optional override for the background                  |
		-- | foreground | optional override for the foreground                  |
		custom = {},
	},
	paragraph = {
		-- Useful context to have when evaluating values.
		-- | text | text value of the node |

		-- Turn on / off paragraph rendering.
		enabled = true,
		-- Additional modes to render paragraphs.
		render_modes = false,
		-- Amount of margin to add to the left of paragraphs.
		-- If a float < 1 is provided it is treated as a percentage of available window space.
		-- Output is evaluated depending on the type.
		-- | function | `value(context)` |
		-- | number   | `value`          |
		left_margin = 0,
		-- Amount of padding to add to the first line of each paragraph.
		-- Output is evaluated using the same logic as 'left_margin'.
		indent = 0,
		-- Minimum width to use for paragraphs.
		min_width = 0,
	},
	code = {
		-- Turn on / off code block & inline code rendering.
		enabled = true,
		-- Additional modes to render code blocks.
		render_modes = false,
		-- Turn on / off sign column related rendering.
		sign = true,
		-- Whether to conceal nodes at the top and bottom of code blocks.
		conceal_delimiters = true,
		-- Turn on / off language heading related rendering.
		language = true,
		-- Determines where language icon is rendered.
		-- | center | center of code block |
		-- | right  | right of code block  |
		-- | left   | left of code block   |
		position = "left",
		-- Whether to include the language icon above code blocks.
		language_icon = true,
		-- Whether to include the language name above code blocks.
		language_name = true,
		-- Whether to include the language info above code blocks.
		language_info = true,
		-- Amount of padding to add around the language.
		-- If a float < 1 is provided it is treated as a percentage of available window space.
		language_pad = 0,
		-- A list of language names for which rendering will be disabled.
		disable = {},
		-- A list of language names for which background highlighting will be disabled.
		-- Likely because that language has background highlights itself.
		-- Use a boolean to make behavior apply to all languages.
		-- Borders above & below blocks will continue to be rendered.
		disable_background = { "diff" },
		-- Width of the code block background.
		-- | block | width of the code block  |
		-- | full  | full width of the window |
		width = "full",
		-- Amount of margin to add to the left of code blocks.
		-- If a float < 1 is provided it is treated as a percentage of available window space.
		-- Margin available space is computed after accounting for padding.
		left_margin = 0,
		-- Amount of padding to add to the left of code blocks.
		-- If a float < 1 is provided it is treated as a percentage of available window space.
		left_pad = 0,
		-- Amount of padding to add to the right of code blocks when width is 'block'.
		-- If a float < 1 is provided it is treated as a percentage of available window space.
		right_pad = 0,
		-- Minimum width to use for code blocks when width is 'block'.
		min_width = 0,
		-- Determines how the top / bottom of code block are rendered.
		-- | none  | do not render a border                               |
		-- | thick | use the same highlight as the code body              |
		-- | thin  | when lines are empty overlay the above & below icons |
		-- | hide  | conceal lines unless language name or icon is added  |
		border = "hide",
		-- Used above code blocks to fill remaining space around language.
		language_border = "█",
		-- Added to the left of language.
		language_left = "",
		-- Added to the right of language.
		language_right = "",
		-- Used above code blocks for thin border.
		above = "▄",
		-- Used below code blocks for thin border.
		below = "▀",
		-- Turn on / off inline code related rendering.
		inline = true,
		-- Icon to add to the left of inline code.
		inline_left = "",
		-- Icon to add to the right of inline code.
		inline_right = "",
		-- Padding to add to the left & right of inline code.
		inline_pad = 0,
		-- Priority to assign to code background highlight.
		priority = 140,
		-- Highlight for code blocks.
		highlight = "RenderMarkdownCode",
		-- Highlight for code info section, after the language.
		highlight_info = "RenderMarkdownCodeInfo",
		-- Highlight for language, overrides icon provider value.
		highlight_language = nil,
		-- Highlight for border, use false to add no highlight.
		highlight_border = "RenderMarkdownCodeBorder",
		-- Highlight for language, used if icon provider does not have a value.
		highlight_fallback = "RenderMarkdownCodeFallback",
		-- Highlight for inline code.
		highlight_inline = "RenderMarkdownCodeInline",
		-- Highlight for inline code left icon, default to reverse of highlight_inline.
		highlight_inline_left = nil,
		-- Highlight for inline code right icon, default to reverse of highlight_inline.
		highlight_inline_right = nil,
		-- Determines how code blocks & inline code are rendered.
		-- | none     | { enabled = false }                           |
		-- | normal   | { language = false }                          |
		-- | language | { disable_background = true, inline = false } |
		-- | full     | uses all default values                       |
		style = "full",
	},
	dash = {
		-- Useful context to have when evaluating values.
		-- | width | width of the current window |

		-- Turn on / off thematic break rendering.
		enabled = true,
		-- Additional modes to render dash.
		render_modes = false,
		-- Replaces '---'|'***'|'___'|'* * *' of 'thematic_break'.
		-- The icon gets repeated across the window's width.
		icon = "─",
		-- Width of the generated line.
		-- If a float < 1 is provided it is treated as a percentage of available window space.
		-- Output is evaluated depending on the type.
		-- | function | `value(context)`    |
		-- | number   | `value`             |
		-- | full     | width of the window |
		width = "full",
		-- Amount of margin to add to the left of dash.
		-- If a float < 1 is provided it is treated as a percentage of available window space.
		left_margin = 0,
		-- Priority to assign to dash.
		priority = nil,
		-- Highlight for the whole line generated from the icon.
		highlight = "RenderMarkdownDash",
	},
	document = {
		-- Turn on / off document rendering.
		enabled = true,
		-- Additional modes to render document.
		render_modes = false,
		-- Ability to conceal arbitrary ranges of text based on lua patterns, @see :h lua-patterns.
		-- Relies entirely on user to set patterns that handle their edge cases.
		conceal = {
			-- Matched ranges will be concealed using character level conceal.
			char_patterns = {},
			-- Matched ranges will be concealed using line level conceal.
			line_patterns = {},
		},
	},
	bullet = {
		-- Useful context to have when evaluating values.
		-- | level | how deeply nested the list is, 1-indexed          |
		-- | index | how far down the item is at that level, 1-indexed |
		-- | value | text value of the marker node                     |

		-- Turn on / off list bullet rendering
		enabled = true,
		-- Additional modes to render list bullets
		render_modes = false,
		-- Replaces '-'|'+'|'*' of 'list_item'.
		-- If the item is a 'checkbox' a conceal is used to hide the bullet instead.
		-- Output is evaluated depending on the type.
		-- | function   | `value(context)`                                    |
		-- | string     | `value`                                             |
		-- | string[]   | `cycle(value, context.level)`                       |
		-- | string[][] | `clamp(cycle(value, context.level), context.index)` |
		icons = { "●", "○", "◆", "◇" },
		-- Replaces 'n.'|'n)' of 'list_item'.
		-- Output is evaluated using the same logic as 'icons'.
		ordered_icons = function(ctx)
			local value = vim.trim(ctx.value)
			local index = tonumber(value:sub(1, #value - 1))
			return ("%d."):format(index > 1 and index or ctx.index)
		end,
		-- Padding to add to the left of bullet point.
		-- Output is evaluated depending on the type.
		-- | function | `value(context)` |
		-- | integer  | `value`          |
		left_pad = 0,
		-- Padding to add to the right of bullet point.
		-- Output is evaluated using the same logic as 'left_pad'.
		right_pad = 0,
		-- Highlight for the bullet icon.
		-- Output is evaluated using the same logic as 'icons'.
		highlight = "RenderMarkdownBullet",
		-- Highlight for item associated with the bullet point.
		-- Output is evaluated using the same logic as 'icons'.
		scope_highlight = {},
		-- Priority to assign to scope highlight.
		scope_priority = nil,
	},
	checkbox = {
		-- Checkboxes are a special instance of a 'list_item' that start with a 'shortcut_link'.
		-- There are two special states for unchecked & checked defined in the markdown grammar.

		-- Turn on / off checkbox state rendering.
		enabled = true,
		-- Additional modes to render checkboxes.
		render_modes = false,
		-- Render the bullet point before the checkbox.
		bullet = false,
		-- Padding to add to the left of checkboxes.
		left_pad = 0,
		-- Padding to add to the right of checkboxes.
		right_pad = 1,
		unchecked = {
			-- Replaces '[ ]' of 'task_list_marker_unchecked'.
			icon = "󰄱 ",
			-- Highlight for the unchecked icon.
			highlight = "RenderMarkdownUnchecked",
			-- Highlight for item associated with unchecked checkbox.
			scope_highlight = nil,
		},
		checked = {
			-- Replaces '[x]' of 'task_list_marker_checked'.
			icon = "󰱒 ",
			-- Highlight for the checked icon.
			highlight = "RenderMarkdownChecked",
			-- Highlight for item associated with checked checkbox.
			scope_highlight = nil,
		},
		-- Define custom checkbox states, more involved, not part of the markdown grammar.
		-- As a result this requires neovim >= 0.10.0 since it relies on 'inline' extmarks.
		-- The key is for healthcheck and to allow users to change its values, value type below.
		-- | raw             | matched against the raw text of a 'shortcut_link'           |
		-- | rendered        | replaces the 'raw' value when rendering                     |
		-- | highlight       | highlight for the 'rendered' icon                           |
		-- | scope_highlight | optional highlight for item associated with custom checkbox |
		-- stylua: ignore
		custom = {
			todo = { raw = "[-]", rendered = "󰥔 ", highlight = "RenderMarkdownTodo", scope_highlight = nil },
		},
		-- Priority to assign to scope highlight.
		scope_priority = nil,
	},
	quote = {
		-- Turn on / off block quote & callout rendering.
		enabled = true,
		-- Additional modes to render quotes.
		render_modes = false,
		-- Replaces '>' of 'block_quote'.
		icon = "▋",
		-- Whether to repeat icon on wrapped lines. Requires neovim >= 0.10. This will obscure text
		-- if incorrectly configured with :h 'showbreak', :h 'breakindent' and :h 'breakindentopt'.
		-- A combination of these that is likely to work follows.
		-- | showbreak      | '  ' (2 spaces)   |
		-- | breakindent    | true              |
		-- | breakindentopt | '' (empty string) |
		-- These are not validated by this plugin. If you want to avoid adding these to your main
		-- configuration then set them in win_options for this plugin.
		repeat_linebreak = false,
		-- Highlight for the quote icon.
		-- If a list is provided output is evaluated by `cycle(value, level)`.
		highlight = {
			"RenderMarkdownQuote1",
			"RenderMarkdownQuote2",
			"RenderMarkdownQuote3",
			"RenderMarkdownQuote4",
			"RenderMarkdownQuote5",
			"RenderMarkdownQuote6",
		},
	},
	pipe_table = {
		-- Turn on / off pipe table rendering.
		enabled = true,
		-- Additional modes to render pipe tables.
		render_modes = false,
		-- Pre configured settings largely for setting table border easier.
		-- | heavy  | use thicker border characters     |
		-- | double | use double line border characters |
		-- | round  | use round border corners          |
		-- | none   | does nothing                      |
		preset = "none",
		-- Determines how individual cells of a table are rendered.
		-- | overlay | writes completely over the table, removing conceal behavior and highlights |
		-- | raw     | replaces only the '|' characters in each row, leaving the cells unmodified |
		-- | padded  | raw + cells are padded to maximum visual width for each column             |
		-- | trimmed | padded except empty space is subtracted from visual width calculation      |
		cell = "padded",
		-- Adjust the computed width of table cells using custom logic.
		cell_offset = function()
			return 0
		end,
		-- Amount of space to put between cell contents and border.
		padding = 1,
		-- Minimum column width to use for padded or trimmed cell.
		min_width = 0,
        -- Characters used to replace table border.
        -- Correspond to top(3), delimiter(3), bottom(3), vertical, & horizontal.
        -- stylua: ignore
        border = {
            '┌', '┬', '┐',
            '├', '┼', '┤',
            '└', '┴', '┘',
            '│', '─',
        },
		-- Turn on / off top & bottom lines.
		border_enabled = true,
		-- Always use virtual lines for table borders instead of attempting to use empty lines.
		-- Will be automatically enabled if indentation module is enabled.
		border_virtual = false,
		-- Gets placed in delimiter row for each column, position is based on alignment.
		alignment_indicator = "━",
		-- Highlight for table heading, delimiter, and the line above.
		head = "RenderMarkdownTableHead",
		-- Highlight for everything else, main table rows and the line below.
		row = "RenderMarkdownTableRow",
		-- Determines how the table as a whole is rendered.
		-- | none   | { enabled = false }        |
		-- | normal | { border_enabled = false } |
		-- | full   | uses all default values    |
		style = "full",
	},
	callout = {
		-- Callouts are a special instance of a 'block_quote' that start with a 'shortcut_link'.
		-- The key is for healthcheck and to allow users to change its values, value type below.
		-- | raw        | matched against the raw text of a 'shortcut_link', case insensitive |
		-- | rendered   | replaces the 'raw' value when rendering                             |
		-- | highlight  | highlight for the 'rendered' text and quote markers                 |
		-- | quote_icon | optional override for quote.icon value for individual callout       |
		-- | category   | optional metadata useful for filtering                              |

		note = {
			raw = "[!NOTE]",
			rendered = "󰋽 Note",
			highlight = "RenderMarkdownInfo",
			category = "github",
		},
		tip = {
			raw = "[!TIP]",
			rendered = "󰌶 Tip",
			highlight = "RenderMarkdownSuccess",
			category = "github",
		},
		important = {
			raw = "[!IMPORTANT]",
			rendered = "󰅾 Important",
			highlight = "RenderMarkdownHint",
			category = "github",
		},
		warning = {
			raw = "[!WARNING]",
			rendered = "󰀪 Warning",
			highlight = "RenderMarkdownWarn",
			category = "github",
		},
		caution = {
			raw = "[!CAUTION]",
			rendered = "󰳦 Caution",
			highlight = "RenderMarkdownError",
			category = "github",
		},
		-- Obsidian: https://help.obsidian.md/Editing+and+formatting/Callouts
		abstract = {
			raw = "[!ABSTRACT]",
			rendered = "󰨸 Abstract",
			highlight = "RenderMarkdownInfo",
			category = "obsidian",
		},
		summary = {
			raw = "[!SUMMARY]",
			rendered = "󰨸 Summary",
			highlight = "RenderMarkdownInfo",
			category = "obsidian",
		},
		tldr = {
			raw = "[!TLDR]",
			rendered = "󰨸 Tldr",
			highlight = "RenderMarkdownInfo",
			category = "obsidian",
		},
		info = {
			raw = "[!INFO]",
			rendered = "󰋽 Info",
			highlight = "RenderMarkdownInfo",
			category = "obsidian",
		},
		todo = {
			raw = "[!TODO]",
			rendered = "󰗡 Todo",
			highlight = "RenderMarkdownInfo",
			category = "obsidian",
		},
		hint = {
			raw = "[!HINT]",
			rendered = "󰌶 Hint",
			highlight = "RenderMarkdownSuccess",
			category = "obsidian",
		},
		success = {
			raw = "[!SUCCESS]",
			rendered = "󰄬 Success",
			highlight = "RenderMarkdownSuccess",
			category = "obsidian",
		},
		check = {
			raw = "[!CHECK]",
			rendered = "󰄬 Check",
			highlight = "RenderMarkdownSuccess",
			category = "obsidian",
		},
		done = {
			raw = "[!DONE]",
			rendered = "󰄬 Done",
			highlight = "RenderMarkdownSuccess",
			category = "obsidian",
		},
		question = {
			raw = "[!QUESTION]",
			rendered = "󰘥 Question",
			highlight = "RenderMarkdownWarn",
			category = "obsidian",
		},
		help = {
			raw = "[!HELP]",
			rendered = "󰘥 Help",
			highlight = "RenderMarkdownWarn",
			category = "obsidian",
		},
		faq = {
			raw = "[!FAQ]",
			rendered = "󰘥 Faq",
			highlight = "RenderMarkdownWarn",
			category = "obsidian",
		},
		attention = {
			raw = "[!ATTENTION]",
			rendered = "󰀪 Attention",
			highlight = "RenderMarkdownWarn",
			category = "obsidian",
		},
		failure = {
			raw = "[!FAILURE]",
			rendered = "󰅖 Failure",
			highlight = "RenderMarkdownError",
			category = "obsidian",
		},
		fail = {
			raw = "[!FAIL]",
			rendered = "󰅖 Fail",
			highlight = "RenderMarkdownError",
			category = "obsidian",
		},
		missing = {
			raw = "[!MISSING]",
			rendered = "󰅖 Missing",
			highlight = "RenderMarkdownError",
			category = "obsidian",
		},
		danger = {
			raw = "[!DANGER]",
			rendered = "󱐌 Danger",
			highlight = "RenderMarkdownError",
			category = "obsidian",
		},
		error = {
			raw = "[!ERROR]",
			rendered = "󱐌 Error",
			highlight = "RenderMarkdownError",
			category = "obsidian",
		},
		bug = {
			raw = "[!BUG]",
			rendered = "󰨰 Bug",
			highlight = "RenderMarkdownError",
			category = "obsidian",
		},
		example = {
			raw = "[!EXAMPLE]",
			rendered = "󰉹 Example",
			highlight = "RenderMarkdownHint",
			category = "obsidian",
		},
		quote = {
			raw = "[!QUOTE]",
			rendered = "󱆨 Quote",
			highlight = "RenderMarkdownQuote",
			category = "obsidian",
		},
		cite = {
			raw = "[!CITE]",
			rendered = "󱆨 Cite",
			highlight = "RenderMarkdownQuote",
			category = "obsidian",
		},
	},
	link = {
		-- Turn on / off inline link icon rendering.
		enabled = true,
		-- Additional modes to render links.
		render_modes = false,
		-- How to handle footnote links, start with a '^'.
		footnote = {
			-- Turn on / off footnote rendering.
			enabled = true,
			-- Inlined with content.
			icon = "󰯔 ",
			-- Custom processing for footnote body to show.
			-- Runs before prefix / suffix are added and superscript processing.
			body = function(ctx)
				return ctx.text
			end,
			-- Replace value with superscript equivalent.
			superscript = true,
			-- Added before link content.
			prefix = "",
			-- Added after link content.
			suffix = "",
		},
		-- Inlined with 'image' elements.
		image = "󰥶 ",
		-- Check custom for 'image' elements.
		image_custom = true,
		-- Inlined with 'email_autolink' elements.
		email = "󰀓 ",
		-- Fallback icon for 'inline_link' and 'uri_autolink' elements.
		hyperlink = "󰌹 ",
		-- Applies to the inlined icon as a fallback.
		highlight = "RenderMarkdownLink",
		-- Applies to the link title.
		highlight_title = "RenderMarkdownLinkTitle",
		-- Applies to WikiLink elements.
		wiki = {
			-- Turn on / off WikiLink rendering.
			enabled = true,
			-- Inlined with content.
			icon = "󱗖 ",
			-- Custom processing for WikiLink body to show.
			body = function()
				return nil
			end,
			-- Applies to the inlined icon.
			highlight = "RenderMarkdownWikiLink",
			-- Highlight for item associated with the WikiLink.
			scope_highlight = nil,
		},
		-- Define custom destination patterns so icons can quickly inform you of what a link
		-- contains. Applies to 'image', 'inline_link', 'uri_autolink', and WikiLink nodes.
		-- When multiple patterns match a link the one with the longer pattern is used.
		-- The key is for healthcheck and to allow users to change its values, value type below.
		-- | pattern   | matched against the destination text                            |
		-- | icon      | gets inlined before the link text                               |
		-- | kind      | optional determines how pattern is checked                      |
		-- |           | pattern | @see :h lua-patterns, is the default if not set       |
		-- |           | suffix  | @see :h vim.endswith()                                |
		-- | priority  | optional used when multiple match, uses pattern length if empty |
		-- | highlight | optional highlight for 'icon', uses fallback highlight if empty |
		custom = {
			web = { pattern = "^http", icon = "󰖟 " },
			apple = { pattern = "apple%.com", icon = " " },
			discord = { pattern = "discord%.com", icon = "󰙯 " },
			github = { pattern = "github%.com", icon = "󰊤 " },
			gitlab = { pattern = "gitlab%.com", icon = "󰮠 " },
			google = { pattern = "google%.com", icon = "󰊭 " },
			hackernews = { pattern = "ycombinator%.com", icon = " " },
			linkedin = { pattern = "linkedin%.com", icon = "󰌻 " },
			microsoft = { pattern = "microsoft%.com", icon = " " },
			neovim = { pattern = "neovim%.io", icon = " " },
			reddit = { pattern = "reddit%.com", icon = "󰑍 " },
			slack = { pattern = "slack%.com", icon = "󰒱 " },
			stackoverflow = { pattern = "stackoverflow%.com", icon = "󰓌 " },
			steam = { pattern = "steampowered%.com", icon = " " },
			twitter = { pattern = "twitter%.com", icon = " " },
			wikipedia = { pattern = "wikipedia%.org", icon = "󰖬 " },
			x = { pattern = "x%.com", icon = " " },
			youtube = { pattern = "youtube[^.]*%.com", icon = "󰗃 " },
			youtube_short = { pattern = "youtu%.be", icon = "󰗃 " },
		},
	},
	sign = {
		-- Turn on / off sign rendering.
		enabled = true,
		-- Priority to assign to sign.
		priority = nil,
		-- Applies to background of sign text.
		highlight = "RenderMarkdownSign",
	},
	inline_highlight = {
		-- Mimics Obsidian inline highlights when content is surrounded by double equals.
		-- The equals on both ends are concealed and the inner content is highlighted.

		-- Turn on / off inline highlight rendering.
		enabled = true,
		-- Additional modes to render inline highlights.
		render_modes = false,
		-- Applies to background of surrounded text.
		highlight = "RenderMarkdownInlineHighlight",
		-- Define custom highlights based on text prefix.
		-- The key is for healthcheck and to allow users to change its values, value type below.
		-- | prefix    | matched against text body, @see :h vim.startswith() |
		-- | highlight | highlight for text body                             |
		custom = {},
	},
	indent = {
		-- Mimic org-indent-mode behavior by indenting everything under a heading based on the
		-- level of the heading. Indenting starts from level 2 headings onward by default.

		-- Turn on / off org-indent-mode.
		enabled = false,
		-- Additional modes to render indents.
		render_modes = false,
		-- Amount of additional padding added for each heading level.
		per_level = 2,
		-- Heading levels <= this value will not be indented.
		-- Use 0 to begin indenting from the very first level.
		skip_level = 1,
		-- Do not indent heading titles, only the body.
		skip_heading = false,
		-- Prefix added when indenting, one per level.
		icon = "▎",
		-- Priority to assign to extmarks.
		priority = 0,
		-- Applied to icon.
		highlight = "RenderMarkdownIndent",
	},
	html = {
		-- Turn on / off all HTML rendering.
		enabled = true,
		-- Additional modes to render HTML.
		render_modes = false,
		comment = {
			-- Useful context to have when evaluating values.
			-- | text | text value of the comment node |

			-- Turn on / off HTML comment concealing.
			conceal = true,
			-- Text to inline before the concealed comment.
			-- Output is evaluated depending on the type.
			-- | function | `value(context)` |
			-- | string   | `value`          |
			-- | nil      | nothing          |
			text = nil,
			-- Highlight for the inlined text.
			highlight = "RenderMarkdownHtmlComment",
		},
		-- HTML tags whose start and end will be hidden and icon shown.
		-- The key is matched against the tag name, value type below.
		-- | icon            | optional icon inlined at start of tag           |
		-- | highlight       | optional highlight for the icon                 |
		-- | scope_highlight | optional highlight for item associated with tag |
		tag = {},
	},
	win_options = {
		-- Window options to use that change between rendered and raw view.

		-- @see :h 'conceallevel'
		conceallevel = {
			-- Used when not being rendered, get user setting.
			default = vim.o.conceallevel,
			-- Used when being rendered, concealed text is completely hidden.
			rendered = 3,
		},
		-- @see :h 'concealcursor'
		concealcursor = {
			-- Used when not being rendered, get user setting.
			default = vim.o.concealcursor,
			-- Used when being rendered, show concealed text in all modes.
			rendered = "",
		},
	},
	overrides = {
		-- More granular configuration mechanism, allows different aspects of buffers to have their own
		-- behavior. Values default to the top level configuration if no override is provided. Supports
		-- the following fields:
		--   enabled, render_modes, debounce, anti_conceal, bullet, callout, checkbox, code, dash,
		--   document, heading, html, indent, inline_highlight, latex, link, padding, paragraph,
		--   pipe_table, quote, sign, win_options, yaml

		-- Override for different buflisted values, @see :h 'buflisted'.
		buflisted = {},
		-- Override for different buftype values, @see :h 'buftype'.
		buftype = {
			nofile = {
				render_modes = true,
				padding = { highlight = "NormalFloat" },
				sign = { enabled = false },
			},
		},
		-- Override for different filetype values, @see :h 'filetype'.
		filetype = {},
		-- Override for preview buffer.
		preview = {
			render_modes = true,
		},
	},
	custom_handlers = {
		-- Mapping from treesitter language to user defined handlers.
		-- @see [Custom Handlers](doc/custom-handlers.md)
	},
	yaml = {
		-- Turn on / off all yaml rendering.
		enabled = true,
		-- Additional modes to render yaml.
		render_modes = false,
	},
})
