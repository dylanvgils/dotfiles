vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

vim.cmd([[colorscheme onedark]])
vim.opt.clipboard = "unnamedplus"
