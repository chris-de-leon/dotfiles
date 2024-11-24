-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- https://www.reddit.com/r/neovim/comments/10aqgmy/tab_isnt_working_for_me/
vim.keymap.set("n", "<TAB>", ">>")
vim.keymap.set("n", "<S-TAB>", "<<")
vim.keymap.set("i", "<TAB>", "  ")
vim.keymap.set("i", "<S-TAB>", "<C-O>2dh")
vim.keymap.set("v", "<TAB>", ">gv")
vim.keymap.set("v", "<S-TAB>", "<gv")
