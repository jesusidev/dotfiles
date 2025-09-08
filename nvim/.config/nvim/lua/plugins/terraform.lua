return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Terraform LSP
        terraformls = {},
      },
    },
  },
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "terraform-ls",
      })
    end,
  },
}
