return {
  -- Install Atom Onedark theme
  { "navarasu/onedark.nvim" },

  -- Configure LazyVim to load onedark
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "onedark",
    },
  },
}
