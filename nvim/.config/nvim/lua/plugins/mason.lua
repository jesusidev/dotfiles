return {
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    opts = {
      ensure_installed = {
        -- Go
        "gopls",
        "delve",
        -- Java tools (nvim-jdtls starts the server, not lspconfig)
        "jdtls",
        "java-test",
        "java-debug-adapter",
      },
      ui = {
        border = "rounded",
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
      max_concurrent_installers = 10,
    },
  },

  {
    "williamboman/mason-lspconfig.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    opts = {
      automatic_installation = true,
      ensure_installed = {
        -- Go only; DO NOT add "jdtls" here
        "gopls",
      },
    },
    config = function(_, opts)
      local ok, mlsp = pcall(require, "mason-lspconfig")
      if not ok then
        return
      end
      mlsp.setup(opts or {})
      mlsp.setup_handlers({
        function(server)
          if server == "jdtls" then
            return
          end -- nvim-jdtls handles Java
          local ok_lsp, lsp = pcall(require, "lspconfig")
          if ok_lsp and lsp[server] then
            lsp[server].setup({})
          end
        end,
      })
    end,
  },
}

