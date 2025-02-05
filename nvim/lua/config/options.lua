-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.relativenumber = false

-- https://neovim.discourse.group/t/commentstring-for-terraform-files-not-set/4066/2
-- Define what comments should look like for cairo files (mini.comment plugin will automatically use this)
-- vim.api.nvim_create_autocmd("FileType", {
--   group = vim.api.nvim_create_augroup("CairoComment", { clear = true }),
--   callback = function(ev)
--     vim.bo[ev.buf].commentstring = "// %s"
--   end,
--   pattern = { "cairo" },
-- })
