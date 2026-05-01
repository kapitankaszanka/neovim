-- lua/plugins/ai.lua

return {
    {
        "olimorris/codecompanion.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            { "folke/which-key.nvim", optional = true },
        },
        init = function()
            -- Add to Which-Key BEFORE the plugin loads
            local ok, wk = pcall(require, "which-key")
            if ok then
                wk.add({
                    { "<leader>g", group = "AI (Gemini)" },
                })
            end
        end,
        keys = {
            { "<leader>gc", "<cmd>CodeCompanionChat Toggle<cr>", mode = { "n", "v" }, desc = "AI: Toggle Chat" },
            { "<leader>ga", "<cmd>CodeCompanionActions<cr>",     mode = { "n", "v" }, desc = "AI: Actions" },
            { "<leader>ge", "<cmd>CodeCompanion /explain<cr>",   mode = "v",          desc = "AI: Explain code" },
            { "<leader>gf", "<cmd>CodeCompanion /fix<cr>",       mode = "v",          desc = "AI: Fix code" },
            { "<leader>gd", "<cmd>CodeCompanion /doc<cr>",       mode = "n",          desc = "AI: Generate doc" },
        },
        config = function()
            require("codecompanion").setup({
                adapters = {
                    gemini = function()
                        return require("codecompanion.adapters").extend("gemini", {
                            name = "Gemini 2.0 Flash",
                            schema = {
                                model = { default = "gemini-2.0-flash" },
                            },
                            env = {
                                api_key = "GEMINI_API_KEY",
                            },
                        })
                    end,
                    gemini_pro = function()
                        return require("codecompanion.adapters").extend("gemini", {
                            name = "Gemini 2.5 Pro",
                            schema = {
                                model = { default = "gemini-2.5-pro" },
                            },
                            env = {
                                api_key = "GEMINI_API_KEY",
                            },
                        })
                    end,
                },
                strategies = {
                    chat = { adapter = "gemini" },
                    inline = { adapter = "gemini" },
                    agent = { adapter = "gemini" },
                },
            })
        end
    },
}
