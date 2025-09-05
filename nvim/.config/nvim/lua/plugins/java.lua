return {
    -- Spring Boot commands + keymaps (global)
    {
        "folke/which-key.nvim",
        init = function()
            local uv = vim.uv or vim.loop

            local function exists(p)
                return uv.fs_stat(p) ~= nil
            end

            local function find_root()
                local markers = { "mvnw", "gradlew", "pom.xml", "build.gradle", "build.gradle.kts", ".git" }
                local cwd = uv.cwd()
                local found = (vim.fs and vim.fs.find) and vim.fs.find(markers, { path = cwd, upward = true })[1] or nil
                if found then
                    return (vim.fs and vim.fs.dirname) and vim.fs.dirname(found) or cwd
                end
                return cwd
            end

            -- State for background terminals
            local term_state = {
                run = { buf = nil, win = nil },
                test = { buf = nil, win = nil },
            }

            local function ensure_term_buf(kind)
                local state = term_state[kind]
                if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
                    return state.buf
                end
                local buf = vim.api.nvim_create_buf(false, false)
                vim.api.nvim_set_option_value("bufhidden", "hide", { buf = buf })
                vim.api.nvim_set_option_value("swapfile", false, { buf = buf })
                state.buf = buf
                return buf
            end

            local function start_in_background(kind, argv, cwd, title)
                local state = term_state[kind]
                local buf = ensure_term_buf(kind)

                local tmp_win = vim.api.nvim_open_win(buf, true, {
                    relative = "editor",
                    width = 1,
                    height = 1,
                    row = 0,
                    col = 0,
                    style = "minimal",
                    focusable = false,
                    zindex = 1,
                })

                vim.notify(("%s: starting [%s] in %s"):format(title, table.concat(argv, " "), cwd))
                vim.fn.termopen(argv, {
                    cwd = cwd,
                    on_exit = function(_, code)
                        local msg = ("%s: %s"):format(title,
                            code == 0 and "completed" or ("failed (exit " .. code .. ")"))
                        vim.schedule(function()
                            vim.notify(msg, code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR)
                        end)
                    end,
                })

                if tmp_win and vim.api.nvim_win_is_valid(tmp_win) then
                    pcall(vim.api.nvim_win_close, tmp_win, true)
                end
            end

            local function toggle_term(kind, title)
                local state = term_state[kind]
                if state.win and vim.api.nvim_win_is_valid(state.win) then
                    pcall(vim.api.nvim_win_close, state.win, true)
                    state.win = nil
                    return
                end
                local buf = ensure_term_buf(kind)
                vim.cmd("botright 15split")
                state.win = vim.api.nvim_get_current_win()
                vim.api.nvim_win_set_buf(state.win, buf)
                vim.cmd("startinsert")
                vim.notify(title .. " output shown")
            end

            vim.api.nvim_create_user_command("SpringBootRun", function()
                local root = find_root()
                local use_gradle = exists(root .. "/gradlew") or exists(root .. "/build.gradle") or
                    exists(root .. "/build.gradle.kts")
                local exec = use_gradle and (exists(root .. "/gradlew") and "./gradlew" or "gradle")
                    or (exists(root .. "/mvnw") and "./mvnw" or "mvn")
                local args = use_gradle and { "bootRun" } or { "spring-boot:run" }
                local argv = { exec }
                vim.list_extend(argv, args)
                start_in_background("run", argv, root, "Spring Boot Run")
            end, {})

            vim.api.nvim_create_user_command("SpringBootTest", function()
                local root = find_root()
                local use_gradle = exists(root .. "/gradlew") or exists(root .. "/build.gradle") or
                    exists(root .. "/build.gradle.kts")
                local exec = use_gradle and (exists(root .. "/gradlew") and "./gradlew" or "gradle")
                    or (exists(root .. "/mvnw") and "./mvnw" or "mvn")
                local argv = { exec, "test" }
                start_in_background("test", argv, root, "Spring Boot Test")
            end, {})

            vim.api.nvim_create_user_command("SpringBootToggleRun", function()
                toggle_term("run", "Spring Boot Run")
            end, {})

            vim.api.nvim_create_user_command("SpringBootToggleTest", function()
                toggle_term("test", "Spring Boot Test")
            end, {})
        end,
        keys = {
            { "<leader>jr", "<cmd>SpringBootRun<cr>",        desc = "Spring Boot: Run (background)" },
            { "<leader>jt", "<cmd>SpringBootTest<cr>",       desc = "Spring Boot: Test (background)" },
            { "<leader>jR", "<cmd>SpringBootToggleRun<cr>",  desc = "Spring Boot: Toggle Run Output" },
            { "<leader>jT", "<cmd>SpringBootToggleTest<cr>", desc = "Spring Boot: Toggle Test Output" },

            -- JDTLS maintenance
            { "<leader>ji", "<cmd>JavaImport<cr>",           desc = "Java: Import/Reload Project" },
            { "<leader>jb", "<cmd>JavaRebuild<cr>",          desc = "Java: Rebuild Project" },
            { "<leader>js", "<cmd>JavaUpdateSources<cr>",    desc = "Java: Update Source Paths" },
        },
    },

    -- Ensure Java tooling is installed via Mason
    {
        "williamboman/mason.nvim",
        opts = function(_, opts)
            opts = opts or {}
            opts.ensure_installed = opts.ensure_installed or {}
            local tools = { "jdtls", "java-test", "java-debug-adapter" }
            for _, t in ipairs(tools) do
                if not vim.tbl_contains(opts.ensure_installed, t) then
                    table.insert(opts.ensure_installed, t)
                end
            end
            return opts
        end,
    },

    -- Disable nvim-lspconfig's jdtls and stop any bare jdtls client on attach
    {
        "neovim/nvim-lspconfig",
        priority = 1000, -- ensure this runs before any other lspconfig setups
        opts = {
            servers = {
                jdtls = false,
            },
        },
        init = function()
            -- Hard-disable bare lspconfig jdtls
            local ok_lsp, lspconfig = pcall(require, "lspconfig")
            if ok_lsp then
                -- Stub out lspconfig.jdtls.setup so no one can start it
                if lspconfig.jdtls and type(lspconfig.jdtls.setup) == "function" then
                    lspconfig.jdtls.setup = function(_) end
                end
                -- Remove the registered jdtls config to avoid auto-start from other integrations
                local ok_cfg, configs = pcall(require, "lspconfig.configs")
                if ok_cfg and configs.jdtls then
                    configs.jdtls = nil
                end
            end

            -- Fallback: if a bare "jdtls" still attaches, stop it immediately
            local aug = vim.api.nvim_create_augroup("KillBareJDTLS", { clear = true })
            vim.api.nvim_create_autocmd("LspAttach", {
                group = aug,
                callback = function(args)
                    local client = vim.lsp.get_client_by_id(args.data and args.data.client_id or 0)
                    if client
                        and client.name == "jdtls"
                        and client.config
                        and client.config.cmd
                        and client.config.cmd[1] == "jdtls"
                    then
                        vim.schedule(function()
                            client.stop(true)
                        end)
                    end
                end,
            })
        end,
    },

    -- Disable nvim-lspconfig's jdtls (use nvim-jdtls instead)
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                jdtls = false,
            },
        },
    },

    -- Disable nvim-lspconfig's jdtls (use nvim-jdtls instead)
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                jdtls = false,
            },
        },
    },

    -- Java LSP (JDTLS) with per-project workspaces and debug/test bundles
    {
        "mfussenegger/nvim-jdtls",
        ft = { "java" },
        config = function()
            local ok, jdtls = pcall(require, "jdtls")
            if not ok then
                return
            end

            local mason_registry = require("mason-registry")
            if not mason_registry.has_package("jdtls") then
                vim.notify("JDTLS is not installed. Install via :Mason", vim.log.levels.WARN)
                return
            end

            local jdtls_pkg = mason_registry.get_package("jdtls")
            local jdtls_path = jdtls_pkg:get_install_path()
            local launcher = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
            if launcher == "" then
                vim.notify("JDTLS launcher jar not found", vim.log.levels.ERROR)
                return
            end

            -- ── Lombok: hard-point a real jar on disk ────────────────────────────────
            -- Prefer $LOMBOK_JAR, else default to ~/.local/share/lombok/lombok-1.18.40.jar
            local lombok_path = vim.env.LOMBOK_JAR or vim.fn.expand("~/.local/share/lombok/lombok-1.18.40.jar")
            if vim.fn.filereadable(lombok_path) == 0 then
                vim.notify(
                    "Lombok jar not found at: " ..
                    lombok_path .. "\nSet $LOMBOK_JAR or download to ~/.local/share/lombok/",
                    vim.log.levels.ERROR)
                return
            end
            local lombok_vmarg = "-javaagent:" .. lombok_path
            -- ────────────────────────────────────────────────────────────────────────

            local os_config
            if vim.fn.has("mac") == 1 then
                os_config = "config_mac"
            elseif vim.fn.has("unix") == 1 then
                os_config = "config_linux"
            else
                os_config = "config_win"
            end

            local root_markers = {
                -- Prefer a single stable project root to avoid restarts across submodules
                "settings.gradle", "settings.gradle.kts",
                "mvnw", "gradlew",
                ".git",
            }
            local root_dir = require("jdtls.setup").find_root(root_markers)
            if not root_dir or root_dir == "" then
                return
            end

            -- Stop duplicate jdtls launched as bare "jdtls" for this root
            for _, client in ipairs(vim.lsp.get_active_clients()) do
                if client.name == "jdtls"
                    and client.config
                    and client.config.cmd
                    and client.config.cmd[1] == "jdtls"
                    and (client.config.root_dir == root_dir or client.root_dir == root_dir)
                then
                    client.stop(true)
                end
            end

            -- Helper to execute a JDTLS workspace command against this root
            local function jdtls_exec(command, arguments)
                local client
                for _, c in ipairs(vim.lsp.get_active_clients()) do
                    if c.name == "jdtls" and (c.config and c.config.root_dir == root_dir or c.root_dir == root_dir) then
                        client = c
                        break
                    end
                end
                if not client then
                    vim.notify("JDTLS: client not found for this workspace", vim.log.levels.WARN)
                    return
                end
                client.request("workspace/executeCommand", { command = command, arguments = arguments or {} },
                    function(err)
                        if err then
                            vim.schedule(function()
                                vim.notify("JDTLS command failed: " .. tostring(err.message or err), vim.log.levels
                                    .ERROR)
                            end)
                        end
                    end)
            end

            -- User commands to refresh/import the project model
            vim.api.nvim_create_user_command("JavaImport", function()
                jdtls_exec("java.project.import", { root_dir })
            end, {})

            vim.api.nvim_create_user_command("JavaRebuild", function()
                jdtls_exec("java.project.rebuild", {})
            end, {})

            vim.api.nvim_create_user_command("JavaUpdateSources", function()
                jdtls_exec("java.project.updateSourcePaths", { root_dir })
            end, {})

            -- Stop duplicate jdtls started by nvim-lspconfig for this root
            for _, client in ipairs(vim.lsp.get_active_clients()) do
                if client.name == "jdtls"
                    and client.config
                    and client.config.cmd
                    and client.config.cmd[1] == "jdtls"
                    and client.config.root_dir == root_dir
                then
                    client.stop(true)
                end
            end

            -- Stop duplicate jdtls started by nvim-lspconfig (cmd[1] == "jdtls") for this root
            for _, client in ipairs(vim.lsp.get_active_clients()) do
                if client.name == "jdtls"
                    and client.config
                    and client.config.cmd
                    and client.config.cmd[1] == "jdtls"
                    and client.config.root_dir == root_dir
                then
                    vim.notify("Stopping duplicate jdtls client from nvim-lspconfig", vim.log.levels.WARN)
                    client.stop(true)
                end
            end

            local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
            local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspaces/" .. project_name .. "-lombok"

            -- Build JDTLS command; Lombok args MUST precede the -jar launcher flags
            local cmd = {
                "java",
                "-Declipse.application=org.eclipse.jdt.ls.core.id1",
                "-Dosgi.bundles.defaultStartLevel=4",
                "-Declipse.product=org.eclipse.jdt.ls.core.product",
                "-Dlog.protocol=true",
                "-Dlog.level=ALL",
                "-Xms1g",
                "--add-modules=ALL-SYSTEM",
                "--add-opens", "java.base/java.util=ALL-UNNAMED",
                "--add-opens", "java.base/java.lang=ALL-UNNAMED",
            }
            if lombok_vmarg then
                table.insert(cmd, lombok_vmarg)
            end
            vim.list_extend(cmd, {
                "-jar", launcher,
                "-configuration", jdtls_path .. "/" .. os_config,
                "-data", workspace_dir,
            })

            local bundles = {}
            if mason_registry.has_package("java-debug-adapter") then
                local debug_pkg = mason_registry.get_package("java-debug-adapter")
                local debug_path = debug_pkg:get_install_path()
                local debug_jar = vim.fn.glob(debug_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar")
                if debug_jar ~= "" then
                    table.insert(bundles, debug_jar)
                end
            end
            if mason_registry.has_package("java-test") then
                local test_pkg = mason_registry.get_package("java-test")
                local test_path = test_pkg:get_install_path()
                local test_jars = vim.fn.glob(test_path .. "/extension/server/*.jar", 0, 1)
                if type(test_jars) == "table" then
                    vim.list_extend(bundles, test_jars)
                end
            end

            local config = {
                cmd = cmd,
                root_dir = root_dir,
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
            }

            -- Optional: print the exact cmd once for verification
            -- print("JDTLS cmd:\n" .. table.concat(cmd, " "))

            jdtls.start_or_attach(config)
        end,
    },
}
