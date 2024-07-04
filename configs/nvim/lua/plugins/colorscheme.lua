return {
  -- Add theme
  {
    -- "sainnhe/sonokai",
    -- "tanvirtin/monokai.nvim",
    "ellisonleao/gruvbox.nvim",
    -- "kepano/flexoki-neovim",
    -- "patstockwell/vim-monokai-tasty",
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
