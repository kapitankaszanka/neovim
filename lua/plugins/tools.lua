-- lua/plugins/tools.lua

return {
    -- Typing Tutor
    {
        "NStefan002/speedtyper.nvim",
        branch = "main",
        cmd = "Speedtyper",
        opts = {},
    },

    -- Practice Vim Motions
    {
        "ThePrimeagen/vim-be-good",
        cmd = "VimBeGood",
    },

    -- Markdown Preview
    {
        "iamcco/markdown-preview.nvim",
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        ft = { "markdown" },
        build = function() vim.fn["mkdp#util#install"]() end,
        keys = {
            { "<leader>mp", "<cmd>MarkdownPreviewToggle<CR>", desc = "Markdown: toggle preview" },
        },
    },

    -- ToggleTerm & LazyGit
    {
        "akinsho/toggleterm.nvim",
        version = "*",
        opts = {
            open_mapping = [[<c-\>]],
            direction = 'float',
        },
        keys = {
            { "<leader>tt", "<cmd>ToggleTerm direction=float<CR>",              desc = "Toggle terminal (float)" },
            { "<leader>th", "<cmd>ToggleTerm direction=horizontal size=12<CR>", desc = "Terminal horizontal" },
            { "<leader>tv", "<cmd>ToggleTerm direction=vertical size=80<CR>",   desc = "Terminal vertical" },
            {
                "<leader>gg",
                function()
                    local Terminal = require("toggleterm.terminal").Terminal

                    local function in_git_repo()
                        local ok = vim.fn.systemlist("git rev-parse --is-inside-work-tree")[1]
                        return ok == "true"
                    end

                    if vim.fn.executable("lazygit") == 0 then
                        vim.notify("`lazygit` not found in PATH. Please install it and try again.", vim.log.levels.ERROR)
                        return
                    end
                    if not in_git_repo() then
                        vim.notify("Not inside a Git repository (missing .git).", vim.log.levels.WARN)
                        return
                    end
                    if not _G.lazygit_term then
                        _G.lazygit_term = Terminal:new({
                            cmd = "lazygit",
                            direction = "float",
                            hidden = true,
                            dir = "git_dir",
                        })
                    end
                    _G.lazygit_term:toggle()
                end,
                desc = "LazyGit (float)"
            },
            {
                "<leader>gi",
                function()
                    local Terminal = require("toggleterm.terminal").Terminal
                    if not _G.gemini_cli_term then
                        _G.gemini_cli_term = Terminal:new({
                            cmd = "gemini", -- Change this if your CLI command is different (e.g., 'gemini-cli')
                            direction = "float",
                            hidden = true,
                        })
                    end
                    _G.gemini_cli_term:toggle()
                end,
                desc = "Gemini CLI (Terminal)"
            },
        },
    },

    -- Folds (UFO)
    { "kevinhwang91/promise-async" },
    {
        "kevinhwang91/nvim-ufo",
        event = "VeryLazy",
        dependencies = { "kevinhwang91/promise-async" },
        keys = {
            { "zR", function() require("ufo").openAllFolds() end,  desc = "Folds: open all" },
            { "zM", function() require("ufo").closeAllFolds() end, desc = "Folds: close all" },
            {
                "zp",
                function()
                    local winid = require("ufo").peekFoldedLinesUnderCursor()
                    if not winid then vim.lsp.buf.hover() end
                end,
                desc = "Fold: peek (fallback hover)"
            },
        },
        config = function()
            require("ufo").setup({
                provider_selector = function(_, _, _)
                    return { "treesitter", "indent" }
                end,
                fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
                    local newVirtText = {}
                    local suffix = ("  ↙ %d lines "):format(endLnum - lnum)
                    local sufWidth = vim.fn.strdisplaywidth(suffix)
                    local targetWidth = width - sufWidth
                    local curWidth = 0
                    for _, chunk in ipairs(virtText) do
                        local txt, hl = chunk[1], chunk[2]
                        local chunkWidth = vim.fn.strdisplaywidth(txt)
                        if targetWidth > curWidth + chunkWidth then
                            table.insert(newVirtText, chunk)
                            curWidth = curWidth + chunkWidth
                        else
                            txt = truncate(txt, targetWidth - curWidth)
                            table.insert(newVirtText, { txt, hl })
                            break
                        end
                    end
                    table.insert(newVirtText, { suffix, "Comment" })
                    return newVirtText
                end,
            })
        end,
    },
}
