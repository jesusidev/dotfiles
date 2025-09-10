return {
  {
    "neovim/nvim-lspconfig",
    optional = true,
    -- Patch LazyVim's lsp opts so jdtls is never auto-setup by lspconfig
    opts = {
      servers = {
        jdtls = false, -- explicit "nope"
      },
      setup = {
        -- Returning true here tells LazyVim "we handled this" => skip built-in setup
        jdtls = function()
          return true
        end,
      },
    },
  },
}
