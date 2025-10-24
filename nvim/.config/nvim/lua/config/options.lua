-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
--
vim.opt.wrap = true
vim.opt.relativenumber = false

-- Detect system theme
local handle = io.popen("defaults read -g AppleInterfaceStyle 2>/dev/null")
if handle then
  local result = handle:read("*a")
  handle:close()
  vim.o.background = result:match("Dark") and "dark" or "light"
end

-- Enable inline diagnostics (virtual text)
vim.diagnostic.config({
  virtual_text = {
    spacing = 4,
    source = "if_many",
    prefix = "●",
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    focusable = false,
    style = "minimal",
    border = "rounded",
    source = "always",
    header = "",
    prefix = "",
  },
})
