return {
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      { "<leader>e", ":NvimTreeToggle<cr>", desc = "Nvim Tree Toggle" },
    },
    opts = {},
    config = function()
      require("nvim-tree").setup({
        view = { adaptive_size = true },
        update_focused_file = {
          enable = true,
          update_root = {
            enable = false,
            ignore_list = {},
          },
        },
      })
    end,
  },
}
