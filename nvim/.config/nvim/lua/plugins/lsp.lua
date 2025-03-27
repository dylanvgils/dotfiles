return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        tsserver = {},
        cssls = {
          settings = {
            css = { validate = true },
            scss = { validate = true },
            less = { validate = true },
          },
        },
      },
    },
  },
}
