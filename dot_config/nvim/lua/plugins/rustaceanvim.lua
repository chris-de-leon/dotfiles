-- https://github.com/LazyVim/LazyVim/discussions/5638#discussioncomment-12228999
return {
  "mrcjkb/rustaceanvim",
  opts = {
    server = {
      default_settings = {
        ["rust-analyzer"] = {
          procMacro = {
            ignored = {
              ["async-trait"] = vim.NIL,
            },
          },
        },
      },
    },
  },
}
