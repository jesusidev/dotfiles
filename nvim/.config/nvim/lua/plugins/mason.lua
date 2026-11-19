return {
  {
    "mason-org/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    opts = {
      -- Don't list anything another spec already installs: LazyVim installs each
      -- entry in turn, and a duplicate fails with "Package is already installing".
      -- gopls comes from the Go extra's LSP servers, delve from its DAP spec.
      ensure_installed = {
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
    "mason-org/mason-lspconfig.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason-org/mason.nvim",
    },
    opts = {
      -- In v2.x, handlers are defined in opts
      handlers = {
        -- Default handler for all servers
        function(server_name)
          -- Skip jdtls as it's handled by nvim-jdtls
          if server_name == "jdtls" then
            return
          end
          
          -- Use vim.lsp.config for Neovim 0.11.2+
          if vim.lsp.config and vim.lsp.config[server_name] then
            vim.lsp.enable(server_name)
          end
        end,
      },
    },
  },
}

