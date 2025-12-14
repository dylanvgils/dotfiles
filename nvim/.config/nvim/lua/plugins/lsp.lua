return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        vtsls = {
          settings = {
            javascript = {
              preferences = {
                importModuleSpecifier = "shortest",
                importModuleSpecifierEnding = "auto",
              },
            },
            typescript = {
              preferences = {
                importModuleSpecifier = "shortest",
                importModuleSpecifierEnding = "auto",
              },
            },
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
          format = true,
          workingDirectories = { mode = "auto" },
          codeActionOnSave = { enable = true, mode = "all" },
        },
        tsserver = { enabled = false },
      },
    },
  },
}
