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
    if not ok then return end
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
  vim.keymap.set("n", "]t", function() todo_comments.jump_next() end, { desc = "Next todo comment" })
  vim.keymap.set("n", "[t", function() todo_comments.jump_prev() end, { desc = "Previous todo comment" })
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
      map("v", "<leader>hs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Stage hunk")
      map("v", "<leader>hr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Reset hunk")

      map("n", "<leader>hS", gs.stage_buffer, "Stage buffer")
      map("n", "<leader>hR", gs.reset_buffer, "Reset buffer")
      map("n", "<leader>hu", gs.undo_stage_hunk, "Undo stage hunk")
      map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")

      map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame line")
      map("n", "<leader>hB", gs.toggle_current_line_blame, "Toggle line blame")

      map("n", "<leader>hd", gs.diffthis, "Diff this")
      map("n", "<leader>hD", function() gs.diffthis("~") end, "Diff this ~")

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
    "python", "json", "yaml", "html", "css",
    "markdown", "markdown_inline", "bash", "lua",
    "vim", "dockerfile", "gitignore", "vimdoc", "ruby",
  })

end)

-- Diagnostics, quickfix, and todo list panel
vim.pack.add({ gh("folke/trouble.nvim") })
safe(function()
  require("trouble").setup({ focus = true })

  local keymap = vim.keymap
  keymap.set("n", "<leader>xw", "<cmd>Trouble diagnostics toggle<CR>", { desc = "Open trouble workspace diagnostics" })
  keymap.set("n", "<leader>xd", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", { desc = "Open trouble document diagnostics" })
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
      "html", "cssls", "tailwindcss", "lua_ls",
      "graphql", "emmet_ls", "prismals", "pyright",
    },
    automatic_enable = true,
  })

  require("mason-tool-installer").setup({
    ensure_installed = {
      "prettier", "stylua", "isort", "black", "pylint", "eslint_d",
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
  require("nvim-lsp-file-operations").setup()

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

  vim.lsp.config("svelte", vim.tbl_deep_extend("force", default_config, {
    on_attach = function(client, bufnr)
      vim.api.nvim_create_autocmd("BufWritePost", {
        pattern = { "*.js", "*.ts" },
        callback = function(ctx)
          client.notify("$/onDidChangeTsOrJsFile", { uri = ctx.match })
        end,
      })
    end,
  }))

  vim.lsp.config("graphql", vim.tbl_deep_extend("force", default_config, {
    filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" },
  }))

  vim.lsp.config("emmet_ls", vim.tbl_deep_extend("force", default_config, {
    filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less", "svelte" },
  }))

  vim.lsp.config("lua_ls", vim.tbl_deep_extend("force", default_config, {
    settings = {
      Lua = {
        diagnostics = { globals = { "vim" } },
        completion = { callSnippet = "Replace" },
      },
    },
  }))
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
    callback = function() lint.try_lint() end,
  })

  vim.keymap.set("n", "<leader>l", function() lint.try_lint() end, { desc = "Trigger linting for current file" })
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
  })
  vim.o.conceallevel = 2
end)
