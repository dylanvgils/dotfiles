return {
  {
    "williamboman/mason.nvim",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "neovim/nvim-lspconfig",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
    },
    config = function()
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
          "tsserver",
          "html",
          "cssls",
          "ts_ls",
          "tailwindcss",
          "gopls",
          "templ",
        },
        automatic_installation = true,
      })

      require("mason-tool-installer").setup({
        ensure_installed = {
          "lua-language-server",
          "vim-language-server",
          "typescript-language-server",
          "prettier",
          "stylua",
          "gopls",
          "templ",
          "eslint_d",
        },
      })

      require("lspconfig").tailwindcss.setup({})
    end,
  },
}
