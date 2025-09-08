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
