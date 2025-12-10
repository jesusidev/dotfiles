return {
  "kndndrj/nvim-dbee",
  dependencies = {
    "MunifTanjim/nui.nvim",
  },
  build = function()
    require("dbee").install()
  end,
  config = function()
    require("dbee").setup({
      sources = {
        require("dbee.sources").MemorySource:new({
          -- Add your connections here if you want
          -- {
          --   name = "My Database",
          --   type = "postgres",
          --   url = "postgres://user:password@localhost:5432/dbname?sslmode=disable",
          -- },
        }),
        require("dbee.sources").EnvSource:new("DBEE_CONNECTIONS"),
        require("dbee.sources").FileSource:new(vim.fn.stdpath("cache") .. "/dbee/persistence.json"),
      },
    })

    vim.keymap.set("n", "<leader>db", function()
      require("dbee").toggle()
    end, { desc = "Toggle Dbee UI" })
  end,
}
