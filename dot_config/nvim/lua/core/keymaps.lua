local keymap = vim.keymap

-- set leader key to space
vim.g.mapleader = " "

-- use jk to exit insert mode
keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })

-- clear search highlights
keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- remap splits
keymap.set("n", "<leader>w", "<C-w>", { desc = "Split windows" })

-- insert new line
keymap.set("n", "<C-o>", "o<ESC>", { desc = "Insert new line" })

-- cursor movement
keymap.set("n", "H", "0", { desc = "Jump to the start of the line" })
keymap.set("n", "L", "$", { desc = "Jump to the end of the line" })
keymap.set("n", "J", "5j", { desc = "Move cursor down 5 lines" })
keymap.set("n", "K", "5k", { desc = "Move cursor up 5 lines" })

-- comment
keymap.set("n", "<leader>/", "gcc", { desc = "toggle comment", remap = true })
keymap.set("v", "<leader>/", "gc", { desc = "toggle comment", remap = true })
