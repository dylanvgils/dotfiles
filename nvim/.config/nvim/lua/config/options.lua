-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Telescope options
require("telescope").setup({
  defaults = {
    file_ignore_patterns = {
      "node_modules",
    },
  },
})
