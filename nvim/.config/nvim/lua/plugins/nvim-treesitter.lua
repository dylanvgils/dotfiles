return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "c",
          "lua",
          "vim",
          "vimdoc",
          "javascript",
          "html",
          "go",
        },
        sync_install = true,
        highlight = { enable = true },
        indent = { enable = true },
        auto_install = true,
        ignore_install = {},
        modules = {},
      })
    end,
  },
}
