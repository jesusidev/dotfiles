return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        gopls = {
          settings = {
            gopls = {
              analyses = {
                unusedparams = true,
              },
              staticcheck = true,
              gofumpt = true,
            },
          },
        },
      },
    },
  },
  -- gofumpt, goimports, gopls and delve are installed by LazyVim's Go extra
  -- (lazyvim.json); listing them here again made Mason fail with
  -- "Package is already installing".
}
