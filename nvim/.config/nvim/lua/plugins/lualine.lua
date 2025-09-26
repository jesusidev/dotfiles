return {
  "nvim-lualine/lualine.nvim",
  opts = function()
    return {
      winbar = {
        lualine_a = { "mode" },
        lualine_b = { "branch" },
        lualine_c = { "filename" },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" }
      },
      sections = {},
      inactive_sections = {},
      options = {
        component_separators = "",
        section_separators = "",
        globalstatus = true,
        theme = "auto",
      },
    }
  end,
}
