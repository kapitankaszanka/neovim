-- lua/plugins/treesitter.lua

return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = {
                    "python",
                    "lua",
                    "vim",
                    "vimdoc",
                    "bash",
                    "json",
                    "toml",
                    "yaml",
                },
                highlight = { enable = true },
                indent = { enable = true },
            })
        end
    },
    {
        "nvim-treesitter/nvim-treesitter-context",
        opts = {
            enable = true,
            max_lines = 3,
            trim_scope = "outer",
            mode = "cursor",
            separator = "─",
            multiline_threshold = 20,
        },
        keys = {
            { "<leader>uc", function() require("treesitter-context").toggle() end,        desc = "Toggle sticky context" },
            { "[c",         function() require("treesitter-context").go_to_context() end, desc = "Jump to context" },
        },
    },
}
