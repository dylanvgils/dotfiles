return {
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      { "<leader>e", ":NvimTreeToggle<cr>", desc = "Nvim Tree Toggle" },
    },
    config = function()
      require("nvim-tree").setup()
    end,
  },
}
