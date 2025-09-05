return {
    {
        "CopilotC-Nvim/CopilotChat.nvim",
        branch = "canary",
        dependencies = {
            "zbirenbaum/copilot.lua",
            "nvim-lua/plenary.nvim",
        },
        opts = {
            debug = false,
            window = {
                layout = "float",
                relative = "editor",
                border = "rounded",
                width = 0.8,
                height = 0.8,
                title = '🤖 AI Assistant',
                zindex = 100, -- Ensure window stays on top
            },
            headers = {
                user = '👤 You',
                assistant = '🤖 Copilot',
                tool = '🔧 Tool',
            },
            separator = '━━',
            auto_fold = true, -- Automatically folds non-assistant messages
            auto_insert_mode = true,
        },
        keys = {
            { "<leader>ac", "<cmd>CopilotChatToggle<cr>",  desc = "Chat in place" },
            { "<leader>as", "<cmd>CopilotChatStop<cr>",    desc = "Chat Stop current output" },
            { "<leader>ab", "<cmd>CopilotChatModels<cr>",  desc = "Chat with model" },
            { "<leader>ae", "<cmd>CopilotChatExplain<cr>", desc = "Explain code" },
            {
                "<leader>ai",
                ":CopilotChatVisual",
                mode = "x",
                desc = "Chat with selection",
            },
        },
    },
}
