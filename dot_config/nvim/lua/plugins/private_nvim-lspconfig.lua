-- https://github.com/LazyVim/LazyVim/blob/d18331ca891c00d942d6c69e2ab20ee06cbbf90c/lua/lazyvim/plugins/lsp/init.lua#L1
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      diagnostics = {
        update_in_insert = false,
      },
      inlay_hints = {
        enabled = false,
      },
      servers = {
        -- https://github.com/typescript-language-server/typescript-language-server/blob/master/docs/configuration.md#workspacedidchangeconfiguration
        tsserver = {
          settings = {
            typescript = {
              inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayParameterNameHintsWhenArgumentMatchesName = true,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
            },
            javascript = {
              inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayParameterNameHintsWhenArgumentMatchesName = true,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
            },
          },
        },
      },
    },
  },
}
