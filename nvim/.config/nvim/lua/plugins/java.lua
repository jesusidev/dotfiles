return {
  {
    "mfussenegger/nvim-jdtls",
    ft = { "java" },
    config = function()
      local ok_jdtls, jdtls = pcall(require, "jdtls")
      if not ok_jdtls then
        return
      end

      -- ── Root detection ────────────────────────────────────────────────────────
      local function find_root()
        return require("jdtls.setup").find_root({
          "settings.gradle",
          "settings.gradle.kts",
          "mvnw",
          "gradlew",
          ".git",
        })
      end

      -- ── Lombok discovery ─────────────────────────────────────────────────────
      local function find_lombok()
        if vim.env.LOMBOK_JAR and vim.fn.filereadable(vim.env.LOMBOK_JAR) == 1 then
          return vim.env.LOMBOK_JAR
        end
        local candidates = {
          vim.fn.expand("~/.local/share/lombok/lombok-*.jar"),
          vim.fn.expand("~/.local/share/nvim/lombok/lombok-*.jar"),
          vim.fn.expand("~/lombok.jar"),
          "/opt/homebrew/Cellar/lombok/*/libexec/lombok.jar", -- macOS ARM
          "/usr/local/Cellar/lombok/*/libexec/lombok.jar", -- macOS Intel
        }
        for _, pat in ipairs(candidates) do
          local matches = vim.fn.glob(pat, 0, 1)
          if type(matches) == "table" and #matches > 0 then
            table.sort(matches)
            return matches[#matches]
          end
        end
        return nil
      end

      -- ── Build full jdtls config for a root ───────────────────────────────────
      local function build_config(root)
        if not root or root == "" then
          return nil
        end

        local reg_ok, registry = pcall(require, "mason-registry")
        if not reg_ok or not registry.has_package("jdtls") then
          vim.notify("JDTLS is not installed (via Mason).", vim.log.levels.WARN)
          return nil
        end
        local jdt_path = registry.get_package("jdtls"):get_install_path()
        local launcher = vim.fn.glob(jdt_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
        if launcher == "" then
          vim.notify("JDTLS launcher jar not found", vim.log.levels.ERROR)
          return nil
        end

        local lombok_jar = find_lombok()
        if not lombok_jar then
          vim.schedule(function()
            vim.notify(
              "Lombok jar not found. Set $LOMBOK_JAR or place lombok-<ver>.jar in ~/.local/share/lombok/",
              vim.log.levels.WARN
            )
          end)
        end

        local os_cfg = (vim.fn.has("mac") == 1) and "config_mac"
          or ((vim.fn.has("unix") == 1) and "config_linux" or "config_win")

        local project = vim.fn.fnamemodify(root, ":p:h:t")
        local workspace = vim.fn.stdpath("data") .. "/jdtls-workspaces/" .. project .. "-lombok"

        local cmd = {
          "java",
          "-Declipse.application=org.eclipse.jdt.ls.core.id1",
          "-Dosgi.bundles.defaultStartLevel=4",
          "-Declipse.product=org.eclipse.jdt.ls.core.product",
          "-Dlog.protocol=true",
          "-Dlog.level=ALL",
          "-Xms1g",
          "--add-modules=ALL-SYSTEM",
          "--add-opens",
          "java.base/java.util=ALL-UNNAMED",
          "--add-opens",
          "java.base/java.lang=ALL-UNNAMED",
        }
        if lombok_jar then
          table.insert(cmd, "-javaagent:" .. lombok_jar)
          table.insert(cmd, "-Xbootclasspath/a:" .. lombok_jar)
        end
        vim.list_extend(cmd, {
          "-jar",
          launcher,
          "-configuration",
          jdt_path .. "/" .. os_cfg,
          "-data",
          workspace,
        })

        -- Only OSGi plugin jars (skip runner-with-deps & jacocoagent)
        local bundles = {}
        if registry.has_package("java-debug-adapter") then
          local p = registry.get_package("java-debug-adapter"):get_install_path()
          local jar = vim.fn.glob(p .. "/extension/server/com.microsoft.java.debug.plugin-*.jar")
          if jar ~= "" then
            table.insert(bundles, jar)
          end
        end
        if registry.has_package("java-test") then
          local p = registry.get_package("java-test"):get_install_path()
          local all = vim.fn.glob(p .. "/extension/server/*.jar", 0, 1)
          if type(all) == "table" then
            for _, j in ipairs(all) do
              if j:match("com%.microsoft%.java%.test%.plugin%-.+%.jar$") then
                table.insert(bundles, j)
              end
            end
          end
        end

        return {
          cmd = cmd,
          root_dir = root,
          init_options = { bundles = bundles },
          settings = {
            java = {
              eclipse = { downloadSources = true },
              configuration = { updateBuildConfiguration = "interactive", runtimes = {} },
              maven = { downloadSources = true },
              implementationsCodeLens = { enabled = true },
              referencesCodeLens = { enabled = true },
              references = { includeDecompiledSources = true },
              format = { enabled = true },
              signatureHelp = { enabled = true },
              contentProvider = { preferred = "fernflower" },
            },
          },
          on_attach = function(_, bufnr)
            vim.bo[bufnr].tabstop = 4
            vim.bo[bufnr].softtabstop = 4
            vim.bo[bufnr].shiftwidth = 4
            vim.bo[bufnr].expandtab = true
            local aug = vim.api.nvim_create_augroup("JdtlsFmtImports", { clear = false })
            vim.api.nvim_create_autocmd("BufWritePre", {
              group = aug,
              buffer = bufnr,
              callback = function()
                pcall(function()
                  require("jdtls").organize_imports()
                end)
                pcall(function()
                  vim.lsp.buf.format({
                    bufnr = bufnr,
                    timeout_ms = 3000,
                    filter = function(c)
                      return c.name == "jdtls"
                    end,
                  })
                end)
              end,
            })
          end,
        }
      end

      -- Start/attach for EVERY Java buffer
      local perbuf = vim.api.nvim_create_augroup("JdtlsPerBuffer", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        group = perbuf,
        pattern = { "java" },
        callback = function()
          local root = find_root()
          local cfg = build_config(root)
          if cfg then
            require("jdtls").start_or_attach(cfg)
          end
        end,
      })

      -- SAFETY NET: if a bare jdtls attaches, kill it and start the good one
      local guard = vim.api.nvim_create_augroup("JdtlsKillBare", { clear = true })
      vim.api.nvim_create_autocmd("LspAttach", {
        group = guard,
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data and args.data.client_id or 0)
          if not client or client.name ~= "jdtls" then
            return
          end
          local cmd0 = client.config and client.config.cmd and client.config.cmd[1]
          if cmd0 ~= "jdtls" then
            return
          end -- not a bare one
          local buf = args.buf
          local root = find_root()
          local cfg = build_config(root)
          vim.schedule(function()
            pcall(function()
              client.stop(false)
            end)
            if cfg then
              require("jdtls").start_or_attach(cfg)
            end
            -- re-attach buffer just in case
            if buf and vim.api.nvim_buf_is_valid(buf) then
              vim.api.nvim_buf_call(buf, function() end)
            end
          end)
        end,
      })
    end,
  },

  -- Optional: quiet Copilot for Java while stabilizing
  {
    "zbirenbaum/copilot.lua",
    optional = true,
    opts = function(_, opts)
      opts = opts or {}
      opts.filetypes = opts.filetypes or {}
      opts.filetypes.java = false
      return opts
    end,
  },
}
