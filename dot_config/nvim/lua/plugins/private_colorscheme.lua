return {
  -- Add theme
  {
    "ellisonleao/gruvbox.nvim",
    lazy = false,
    priority = 1000,
  },

  -- Configure LazyVim to load theme
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "gruvbox",
    },
  },
}
