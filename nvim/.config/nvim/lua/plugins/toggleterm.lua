return {
    "akinsho/toggleterm.nvim",
    version = "*",
    opts = {
        direction = "float",
        close_on_exit = true,
        start_in_insert = true,
        shade_terminals = true,
        float_opts = {
            border = "curved",
            width = function()
                return math.floor(vim.o.columns * 0.6)
            end,
            height = function()
                return math.floor(vim.o.lines * 0.6)
            end,
            winblend = 0,
        },
    },
    config = function(_, opts)
        require("toggleterm").setup(opts)
    end,
}
