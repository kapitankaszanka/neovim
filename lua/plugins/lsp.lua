-- lua/plugins/lsp.lua

return {
    { "williamboman/mason.nvim", config = true },
    { "williamboman/mason-lspconfig.nvim" },
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "b0o/SchemaStore.nvim",
        },
        config = function()
            local tb = require("telescope.builtin")
            local mason_lsp = require("mason-lspconfig")
            
            mason_lsp.setup({
                ensure_installed = {
                    "basedpyright",
                    "ruff",
                    "gopls",
                    "clangd",
                    "jsonls",
                    "terraformls",
                    "lua_ls",
                    "marksman",
                }
            })

            local capabilities = require("cmp_nvim_lsp").default_capabilities()
            local on_attach = function(_, bufnr)
                local nmap = function(keys, func, desc) vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc }) end
                nmap("gd", tb.lsp_definitions, "LSP: Definitions (picker)")
                nmap("gD", "<cmd>tab split | lua vim.lsp.buf.definition()<CR>", "LSP: Definition in new tab")
                nmap("gr", tb.lsp_references, "LSP: References")
                nmap("K", vim.lsp.buf.hover, "LSP: Hover")
                nmap("<leader>rn", vim.lsp.buf.rename, "LSP: Rename")
                nmap("<leader>ca", vim.lsp.buf.code_action, "LSP: Code Action")
                nmap("[d", vim.diagnostic.goto_prev, "LSP: Prev diagnostic")
                nmap("]d", vim.diagnostic.goto_next, "LSP: Next diagnostic")
                nmap("<leader>fd", function() vim.lsp.buf.format({ async = true }) end, "LSP: Format buffer")
            end

            -- basedpyright
            vim.lsp.config('basedpyright', {
                capabilities = capabilities,
                on_attach = on_attach,
                settings = {
                    basedpyright = {
                        analysis = {
                            autoImportCompletions = true,
                            useLibraryCodeForTypes = true,
                            diagnosticMode = "openFilesOnly",
                            autoSearchPaths = true,
                        }
                    }
                }
            })
            vim.lsp.enable('basedpyright')

            -- ruff
            vim.lsp.config('ruff', {
                capabilities = capabilities,
                on_attach = function(client, bufnr)
                    on_attach(client, bufnr)
                    client.server_capabilities.hoverProvider = false
                end,
            })
            vim.lsp.enable('ruff')

            -- gopls
            vim.lsp.config('gopls', {
                capabilities = capabilities,
                on_attach = on_attach,
                settings = {
                    gopls = {
                        analyses = { unusedparams = true, shadow = true },
                        staticcheck = true,
                    },
                },
            })
            vim.lsp.enable('gopls')

            -- marksman
            vim.lsp.config('marksman', { capabilities = capabilities, on_attach = on_attach })
            vim.lsp.enable('marksman')
            
            -- terraformls
            vim.lsp.config('terraformls', {
                capabilities = capabilities,
                on_attach = on_attach,
            })
            vim.lsp.enable('terraformls')

            -- clangd
            vim.lsp.config('clangd', { capabilities = capabilities, on_attach = on_attach })
            vim.lsp.enable('clangd')

            -- jsonls
            vim.lsp.config('jsonls', {
                capabilities = capabilities,
                on_attach = on_attach,
                settings = {
                    json = {
                        schemas = require('schemastore').json.schemas(),
                        validate = { enable = true },
                        format = { enable = true },
                    },
                },
                filetypes = { "json", "tfstate" },
            })
            vim.lsp.enable('jsonls')

            -- lua_ls
            vim.lsp.config('lua_ls', {
                capabilities = capabilities,
                on_attach = on_attach,
                settings = {
                    Lua = {
                        diagnostics = { globals = { 'vim' } },
                        workspace = {
                            checkThirdParty = false,
                            library = vim.api.nvim_get_runtime_file("", true),
                        },
                        telemetry = { enable = false },
                    },
                },
            })
            vim.lsp.enable('lua_ls')

            -- diagnostics UI
            vim.diagnostic.config({
                virtual_text = false,
                signs = true,
                underline = true,
                update_in_insert = false,
                severity_sort = true,
                float = { border = "rounded", source = "if_many", focusable = false },
            })
            vim.keymap.set("n", "<leader>de", function() vim.diagnostic.open_float(nil, { focus = false, border = "rounded" }) end,
                { desc = "Diagnostics: show at cursor" })
            vim.keymap.set("n", "<leader>dt", function()
                local cfg = vim.diagnostic.config()
                vim.diagnostic.config({ virtual_text = not cfg.virtual_text })
            end, { desc = "Diagnostics: toggle virtual text" })
        end
    },
    {
        "stevearc/conform.nvim",
        config = function()
            require("conform").setup({
                formatters_by_ft = {
                    python = { "ruff_organize_imports", "ruff_format" },
                    lua = { "stylua" },
                    json = { "jq" },
                },
                format_on_save = function(bufnr)
                    if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
                        return
                    end
                    return { lsp_fallback = true, timeout_ms = 500 }
                end,
            })

            vim.api.nvim_create_user_command("FormatToggle", function()
                vim.g.disable_autoformat = not vim.g.disable_autoformat
                print("Autoformat: " .. (vim.g.disable_autoformat and "OFF" or "ON"))
            end, {})
        end
    },
    {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
            library = {
                { path = "luvit-meta/library", words = { "vim%.uv" } },
            },
        },
    },
}
