return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        vtsls = {
          settings = {
            javascript = { preferences = { importModuleSpecifier = "shortest", importModuleSpecifierEnding = "auto" } },
            typescript = { preferences = { importModuleSpecifier = "shortest", importModuleSpecifierEnding = "auto" } },
          },
        },
        cssls = {
          settings = {
            css = { validate = true },
            scss = { validate = true },
            less = { validate = true },
          },
        },
        eslint = {
          filetypes = {
            "javascript",
            "javascriptreact",
            "typescript",
            "typescriptreact",
            "json",
            "jsonc",
          },
        },
        -- let eslint own JSON formatting
        jsonls = { settings = { json = { format = { enable = false } } } },
      },
    },
  },
}
