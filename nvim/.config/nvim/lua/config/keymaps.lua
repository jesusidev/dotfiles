-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.api.nvim_set_keymap("i", "jj", "<Esc>", { noremap = false })
vim.api.nvim_set_keymap("i", "jk", "<Esc>", { noremap = false })

-- Toggle a floating terminal rooted at the current buffer's directory
-- Persist the same terminal instance so the session remains alive across toggles
local float_term
local function toggle_float_term_in_buf_dir()
    local Terminal = require("toggleterm.terminal").Terminal
    if not float_term or not vim.api.nvim_buf_is_valid(float_term.bufnr) then
        local dir = vim.fn.expand("%:p") ~= "" and vim.fn.expand("%:p:h") or vim.fn.getcwd()
        float_term = Terminal:new({ direction = "float", dir = dir, hidden = true, close_on_exit = true })
    end
    float_term:toggle()
    -- Ensure the cursor is in the terminal when opened
    vim.schedule(function()
        if float_term and float_term.window and vim.api.nvim_win_is_valid(float_term.window) then
            vim.api.nvim_set_current_win(float_term.window)
            if float_term.bufnr and vim.api.nvim_buf_is_valid(float_term.bufnr) then
                vim.cmd("startinsert")
            end
        end
    end)
end

-- Use <leader>tt in normal/terminal mode to toggle the floating terminal
vim.keymap.set({ "n", "t" }, "<leader>tt", toggle_float_term_in_buf_dir, { desc = "Toggle Float Terminal (buffer dir)" })

-- Java project helpers: build, run, test, open test report
local Terminal = require("toggleterm.terminal").Terminal

local function find_project_root()
    local markers = { 'gradlew', 'mvnw', 'pom.xml', 'build.gradle', 'settings.gradle' }
    local path = vim.fn.expand('%:p')
    if path == '' then
        return vim.fn.getcwd()
    end
    local dir = vim.fn.fnamemodify(path, ':p:h')
    while dir and dir ~= '/' do
        for _, m in ipairs(markers) do
            if vim.fn.globpath(dir, m) ~= '' or vim.fn.filereadable(dir .. '/' .. m) == 1 then
                return dir
            end
        end
        local parent = vim.fn.fnamemodify(dir, ':h')
        if parent == dir then
            break
        end
        dir = parent
    end
    return vim.fn.getcwd()
end

local function detect_build_tool(root)
    if vim.fn.filereadable(root .. '/gradlew') == 1 or vim.fn.filereadable(root .. '/build.gradle') == 1 or vim.fn.filereadable(root .. '/settings.gradle') == 1 then
        return 'gradle'
    end
    if vim.fn.filereadable(root .. '/mvnw') == 1 or vim.fn.filereadable(root .. '/pom.xml') == 1 then
        return 'maven'
    end
    return nil
end

-- persistent terminals store (key -> Terminal)
local persistent_terms = {}

local function run_in_float(cmd, cwd, save_as)
    cwd = cwd or find_project_root()
    local term = Terminal:new({ cmd = cmd, direction = 'float', dir = cwd, close_on_exit = false })
    -- if a save key was provided, remember this terminal so it can be toggled later
    if save_as and type(save_as) == 'string' then
        persistent_terms[save_as] = term
    end
    term:toggle()
    -- enter insert mode in the terminal
    vim.schedule(function()
        if term.window and vim.api.nvim_win_is_valid(term.window) then
            vim.api.nvim_set_current_win(term.window)
            vim.cmd('startinsert')
        end
    end)
    return term
end

local function toggle_persistent_term(name)
    local t = persistent_terms[name]
    if not t then
        vim.notify('No persistent terminal named: ' .. name, vim.log.levels.WARN)
        return
    end
    -- Toggle visibility of the terminal
    t:toggle()
    -- focus the terminal when shown
    vim.schedule(function()
        if t.window and vim.api.nvim_win_is_valid(t.window) then
            vim.api.nvim_set_current_win(t.window)
            vim.cmd('startinsert')
        end
    end)
end

local function java_build()
    local root = find_project_root()
    local tool = detect_build_tool(root)
    if tool == 'gradle' then
        local gw = root .. '/gradlew'
        local cmd = (vim.fn.filereadable(gw) == 1 and './gradlew build' or 'gradle build')
        run_in_float(cmd, root, 'java_build')
    elseif tool == 'maven' then
        run_in_float('mvn -B -e -DskipTests=false verify', root, 'java_build')
    else
        vim.notify('No Gradle/Maven build detected in project', vim.log.levels.WARN)
    end
end

local function java_run()
    local root = find_project_root()
    local tool = detect_build_tool(root)
    if tool == 'gradle' then
        local cmd = (vim.fn.filereadable(root .. '/gradlew') == 1 and './gradlew bootRun' or 'gradle run')
        run_in_float(cmd, root, 'java_run')
    elseif tool == 'maven' then
        -- maven exec plugin required; try exec:java
        run_in_float('mvn -B exec:java', root, 'java_run')
    else
        vim.notify('No Gradle/Maven build detected in project', vim.log.levels.WARN)
    end
end

local function java_test()
    local root = find_project_root()
    local tool = detect_build_tool(root)
    local class = vim.fn.expand('%:t:r')
    if class == '' then
        vim.notify('No filename detected for test run', vim.log.levels.WARN)
        return
    end
    if tool == 'gradle' then
        -- run tests matching the current class name
        local cmd = string.format('%s test --tests "*%s*"', (vim.fn.filereadable(root .. '/gradlew') == 1 and './gradlew' or 'gradle'), class)
        run_in_float(cmd, root, 'java_test')
    elseif tool == 'maven' then
        local cmd = string.format('mvn -B -Dtest=%s test', class)
        run_in_float(cmd, root, 'java_test')
    else
        vim.notify('No Gradle/Maven build detected in project', vim.log.levels.WARN)
    end
end

-- Run all tests in the project
local function java_test_all()
    local root = find_project_root()
    local tool = detect_build_tool(root)
    if tool == 'gradle' then
        local cmd = (vim.fn.filereadable(root .. '/gradlew') == 1 and './gradlew test' or 'gradle test')
        run_in_float(cmd, root, 'java_test_all')
    elseif tool == 'maven' then
        run_in_float('mvn -B test', root, 'java_test_all')
    else
        vim.notify('No Gradle/Maven build detected in project', vim.log.levels.WARN)
    end
end

local function open_test_report()
    local root = find_project_root()
    local gradle_report = root .. '/build/reports/tests/test/index.html'
    local maven_report = root .. '/target/site/surefire-report.html'
    local alternate_maven = root .. '/target/surefire-reports/index.html'
    local opener = vim.fn.executable('open') == 1 and 'open' or (vim.fn.executable('xdg-open') == 1 and 'xdg-open' or nil)
    local report = nil
    if vim.fn.filereadable(gradle_report) == 1 then
        report = gradle_report
    elseif vim.fn.filereadable(maven_report) == 1 then
        report = maven_report
    elseif vim.fn.filereadable(alternate_maven) == 1 then
        report = alternate_maven
    else
        vim.notify('No test report found. Run tests first.', vim.log.levels.INFO)
        return
    end
    -- Open the report in the system default browser (non-blocking)
    if not opener then
        vim.notify('No system opener (open/xdg-open) found to open the report', vim.log.levels.WARN)
        return
    end
    local ok, jid = pcall(function()
        -- use a list form when possible to avoid shell escaping issues
        return vim.fn.jobstart({ opener, report }, { detach = true })
    end)
    if ok and jid and tonumber(jid) and tonumber(jid) > 0 then
        vim.notify('Opening test report: ' .. report, vim.log.levels.INFO)
    else
        vim.notify('Failed to open test report: ' .. tostring(jid), vim.log.levels.ERROR)
    end
end

-- Keymaps under <leader>j
vim.keymap.set('n', '<leader>jb', java_build, { desc = 'Java: Build project' })
vim.keymap.set('n', '<leader>jr', java_run, { desc = 'Java: Run project' })
vim.keymap.set('n', '<leader>jt', java_test, { desc = 'Java: Run tests (current file/class)' })
vim.keymap.set('n', '<leader>jo', open_test_report, { desc = 'Java: Open test report in browser' })
-- Toggle the persistent Java terminals (build/run/test)
vim.keymap.set('n', '<leader>jB', function() toggle_persistent_term('java_build') end, { desc = 'Java: Toggle build terminal' })
vim.keymap.set('n', '<leader>jR', function() toggle_persistent_term('java_run') end, { desc = 'Java: Toggle run terminal' })
vim.keymap.set('n', '<leader>jT', function() toggle_persistent_term('java_test') end, { desc = 'Java: Toggle test terminal' })
-- Run all tests and toggle its terminal
vim.keymap.set('n', '<leader>ja', java_test_all, { desc = 'Java: Run all tests' })
vim.keymap.set('n', '<leader>jA', function() toggle_persistent_term('java_test_all') end, { desc = 'Java: Toggle all-tests terminal' })

-- Debugging keymaps (nvim-dap)
do
    local ok_dap, dap = pcall(require, 'dap')
    local ok_ui, dapui = pcall(require, 'dapui')

    if not ok_dap then
        vim.notify('nvim-dap not installed; debug keymaps disabled', vim.log.levels.INFO)
    end

    -- basic debug mappings (function keys)
    vim.keymap.set('n', '<F5>', function() if ok_dap then dap.continue() else vim.notify('dap not available', vim.log.levels.WARN) end end, { desc = 'Debug: Continue' })
    vim.keymap.set('n', '<F10>', function() if ok_dap then dap.step_over() else vim.notify('dap not available', vim.log.levels.WARN) end end, { desc = 'Debug: Step over' })
    vim.keymap.set('n', '<F11>', function() if ok_dap then dap.step_into() else vim.notify('dap not available', vim.log.levels.WARN) end end, { desc = 'Debug: Step into' })
    vim.keymap.set('n', '<F12>', function() if ok_dap then dap.step_out() else vim.notify('dap not available', vim.log.levels.WARN) end end, { desc = 'Debug: Step out' })

    -- leader mappings for debug actions
    vim.keymap.set('n', '<leader>dc', function() if ok_dap then dap.continue() else vim.notify('dap not available', vim.log.levels.WARN) end end, { desc = 'Debug: Continue' })
    vim.keymap.set('n', '<leader>db', function() if ok_dap then dap.toggle_breakpoint() else vim.notify('dap not available', vim.log.levels.WARN) end end, { desc = 'Debug: Toggle breakpoint' })
    vim.keymap.set('n', '<leader>dB', function()
        if not ok_dap then vim.notify('dap not available', vim.log.levels.WARN) return end
        vim.ui.input({ prompt = 'Breakpoint condition: ' }, function(input)
            if input then dap.set_breakpoint(input) end
        end)
    end, { desc = 'Debug: Conditional breakpoint' })
    vim.keymap.set('n', '<leader>dr', function() if ok_dap then dap.repl.open() else vim.notify('dap not available', vim.log.levels.WARN) end end, { desc = 'Debug: Open REPL' })
    vim.keymap.set('n', '<leader>dl', function() if ok_dap then dap.run_last() else vim.notify('dap not available', vim.log.levels.WARN) end end, { desc = 'Debug: Run last' })

    -- dap-ui toggle
    vim.keymap.set('n', '<leader>du', function()
        if not ok_dap then vim.notify('dap not available', vim.log.levels.WARN) return end
        if ok_ui then dapui.toggle() else vim.notify('dapui not installed', vim.log.levels.WARN) end
    end, { desc = 'Debug: Toggle DAP UI' })

    -- Java-specific: setup jdtls dap integration (if jdtls available)
    vim.keymap.set('n', '<leader>jd', function()
        if not ok_dap then vim.notify('dap not available', vim.log.levels.WARN) return end
        local ok_jdtls, jdtls = pcall(require, 'jdtls')
        if not ok_jdtls then
            vim.notify('jdtls not available', vim.log.levels.WARN)
            return
        end
        -- try to setup dap for jdtls; this will use bundles configured when jdtls started
        pcall(function()
            if jdtls.setup_dap then
                jdtls.setup_dap({ hotcodereplace = 'auto' })
                vim.notify('jdtls dap setup called', vim.log.levels.INFO)
            else
                vim.notify('jdtls.setup_dap not provided by nvim-jdtls', vim.log.levels.WARN)
            end
        end)
    end, { desc = 'Debug: Setup jdtls DAP' })
end
