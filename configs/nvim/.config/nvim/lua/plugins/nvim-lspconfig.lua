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
        -- tsserver = {
        --   settings = {
        --     typescript = {
        --       inlayHints = {
        --         includeInlayParameterNameHints = "all",
        --         includeInlayParameterNameHintsWhenArgumentMatchesName = true,
        --         includeInlayFunctionParameterTypeHints = true,
        --         includeInlayVariableTypeHints = true,
        --         includeInlayPropertyDeclarationTypeHints = true,
        --         includeInlayFunctionLikeReturnTypeHints = true,
        --         includeInlayEnumMemberValueHints = true,
        --       },
        --     },
        --     javascript = {
        --       inlayHints = {
        --         includeInlayParameterNameHints = "all",
        --         includeInlayParameterNameHintsWhenArgumentMatchesName = true,
        --         includeInlayFunctionParameterTypeHints = true,
        --         includeInlayVariableTypeHints = true,
        --         includeInlayPropertyDeclarationTypeHints = true,
        --         includeInlayFunctionLikeReturnTypeHints = true,
        --         includeInlayEnumMemberValueHints = true,
        --       },
        --     },
        --   },
        -- },

        -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#gopls
        gopls = {
          settings = {
            gopls = {
              -- NOTE: the LazyExtras go extension automatically sets staticcheck to true (you can
              -- confirm this with :LspInfo). This is not desirable because if staticcheck is also
              -- enabled in `.golangci.yml`, then nvim-lint will duplicate the linter messages. To
              -- resolve this, we should disable gopls staticcheck since it's experimental and let
              -- nvim-lint handle it instead: https://go.dev/gopls/settings/staticcheck-bool
              staticcheck = false,
            },
          },
        },
      },
    },
  },
}
