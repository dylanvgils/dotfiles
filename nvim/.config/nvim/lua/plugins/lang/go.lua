if vim.fn.executable("go") == 0 then
  return {}
end

return {
  {
    import = "lazyvim.plugins.extras.lang.go",
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        gopls = {
          settings = {
            gopls = {
              buildFlags = { "-tags=integration" },
            },
          },
        },
      },
    },
  },
}
