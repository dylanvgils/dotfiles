-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.g.autoformat = true

-- Spell checking
vim.opt.spell = true
vim.opt.spelllang = { "en" }

-- Disable the lazyvim order check, since we are importing the
-- configuration files through plugins. To conditionally import
-- the extra(s).
vim.g.lazyvim_check_order = false
