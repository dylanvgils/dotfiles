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

-- Register the eslint LSP as a formatter in LazyVim's format pipeline so
-- format-on-save (and <leader>cf) applies ESLint fixes. Respects the
-- autoformat toggle (<leader>uf / vim.g.autoformat). Requires the
-- linting.eslint extra.
vim.g.lazyvim_eslint_auto_format = true
