-- lua/plugins/ui.lua

return {
    {
        "folke/tokyonight.nvim",
        priority = 1000,
        config = function()
            vim.cmd.colorscheme("tokyonight-night")
        end
    },

    {
        "nvim-lualine/lualine.nvim",
        config = function()
            require("lualine").setup({ options = { theme = "tokyonight" } })
        end
    },

    { "folke/which-key.nvim", event = "VeryLazy", config = true },

    {
        "arnamak/stay-centered.nvim",
        lazy = false,
        opts = {
            enabled = true,
            allow_scroll_move = true,
            disable_on_mouse = true,
            skip_filetypes = { "TelescopePrompt", "toggleterm", "help", "lazy" },
        },
    },
}
