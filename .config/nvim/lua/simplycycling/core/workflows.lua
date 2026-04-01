vim.keymap.set("n", "<leader>on", function()
	vim.cmd("ObsidianTemplate note")
	vim.cmd([[1,/^\S/s/^\n\{1,}//e]])
end)

vim.keymap.set("n", "<leader>of", ":s/\\(# \\)[^_]*_/\\1/ | s/-/ /g<cr>")
vim.keymap.set("n", "<leader>os", ':Telescope find_files search_dirs={"/Users/rsherman/Documents/notes"}<cr>')
