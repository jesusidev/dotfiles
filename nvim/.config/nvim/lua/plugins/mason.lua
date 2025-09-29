return {
  {
    "mason-org/mason.nvim",
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
    "mason-org/mason-lspconfig.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason-org/mason.nvim",
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

      -- Newer versions of mason-lspconfig may not expose setup_handlers.
      -- If it's available use it; otherwise fallback to setting up
      -- lspconfig servers for the ensured servers list.
      if type(mlsp.setup_handlers) == "function" then
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
      else
        local ok_lsp, lsp = pcall(require, "lspconfig")
        if ok_lsp then
          local servers = (opts and opts.ensure_installed) or {}
          for _, server in ipairs(servers) do
            if server ~= "jdtls" and lsp[server] then
              pcall(function()
                lsp[server].setup({})
              end)
            end
          end
        end
      end
    end,
  },
}

