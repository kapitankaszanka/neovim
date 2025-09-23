-- ~/.config/nvim/init.lua

-- lazy.nvim bootstrap
local fn = vim.fn
local lazypath = fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable",
        lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- basic options
vim.g.mapleader = " "
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.termguicolors = true
vim.opt.updatetime = 200
vim.opt.signcolumn = "yes"
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.colorcolumn = "80"
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.list = true
vim.opt.listchars = { space = "·", tab = "→ ", trail = "·", extends = "›", precedes = "‹" }

-- plugins
require("lazy").setup({
    {
        "folke/tokyonight.nvim",
        priority = 1000,
        config = function()
            vim.cmd.colorscheme("tokyonight-night")
        end
    },
    { "nvim-lua/plenary.nvim" },
    { "nvim-telescope/telescope.nvim", tag = "0.1.5" },
    { "lewis6991/gitsigns.nvim",       config = true },
    { "nvim-lualine/lualine.nvim",     config = function() require("lualine").setup({ options = { theme = "tokyonight" } }) end },
    { "folke/which-key.nvim",          event = "VeryLazy",                                                                      config = true },
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = { "python", "lua", "vim", "vimdoc", "bash", "json", "toml", "yaml" },
                highlight = { enable = true },
                indent = { enable = true },
            })
        end
    },
    { "williamboman/mason.nvim",          config = true },
    { "williamboman/mason-lspconfig.nvim" },
    { "neovim/nvim-lspconfig" },
    { "hrsh7th/nvim-cmp" },
    { "hrsh7th/cmp-nvim-lsp" },
    { "hrsh7th/cmp-buffer" },
    { "hrsh7th/cmp-path" },
    { "saadparwaiz1/cmp_luasnip" },
    { "L3MON4D3/LuaSnip",                 version = "v2.*", build = "make install_jsregexp" },
    { "onsails/lspkind.nvim" },
    { "stevearc/conform.nvim" },
    { "akinsho/toggleterm.nvim",          version = "*",    config = true },
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
})

-- telescope
local tb = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", tb.find_files, { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", tb.live_grep, { desc = "Live grep" })
vim.keymap.set("n", "<leader>fb", tb.buffers, { desc = "Buffers" })
vim.keymap.set("n", "<leader>fh", tb.help_tags, { desc = "Help tags" })

-- nvim-cmp
local cmp = require("cmp")
local luasnip = require("luasnip")
local lspkind = require("lspkind")

cmp.setup({
    preselect = cmp.PreselectMode.None,
    -- ważne: 'noselect' zamiast 'noinsert'
    completion = { completeopt = "menu,menuone,noselect" },

    snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },

    mapping = cmp.mapping.preset.insert({
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),

        -- <CR>: tylko jeśli coś JEST wybrane; inaczej newline
        ["<CR>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                local entry = cmp.get_selected_entry()
                if entry then
                    cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
                else
                    -- zamknij menu i wstaw normalny Enter
                    cmp.abort()
                    fallback()
                end
            else
                fallback()
            end
        end, { "i", "s" }),

        ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            else
                fallback()
            end
        end, { "i", "s" }),

        ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { "i", "s" }),
    }),

    sources = cmp.config.sources(
        { { name = "nvim_lsp" }, { name = "luasnip" } },
        { { name = "path" }, { name = "buffer" } }
    ),
    formatting = { format = lspkind.cmp_format({ mode = "symbol_text", maxwidth = 50 }) },
})

-- LSP (Neovim 0.11+)
local mason = require("mason")
local mason_lsp = require("mason-lspconfig")
mason.setup()
mason_lsp.setup({ ensure_installed = { "basedpyright", "ruff", "lua_ls", "gopls", "clangd" } })

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

vim.lsp.config('basedpyright', {
    capabilities = capabilities,
    on_attach = on_attach,
    settings = {
        basedpyright = {
            analysis = {
                autoImportCompletions = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "openFilesOnly",
            }
        }
    }
})
vim.lsp.enable('basedpyright')

vim.lsp.config('ruff', {
    capabilities = capabilities,
    on_attach = function(client, bufnr)
        on_attach(client, bufnr)
        client.server_capabilities.hoverProvider = false
    end,
})
vim.lsp.enable('ruff')

vim.lsp.config('lua_ls',
    { capabilities = capabilities, on_attach = on_attach, settings = { Lua = { diagnostics = { globals = { "vim" } } } } })
vim.lsp.enable('lua_ls')

vim.lsp.config('gopls', { capabilities = capabilities, on_attach = on_attach })
vim.lsp.enable('gopls')

vim.lsp.config('clangd', { capabilities = capabilities, on_attach = on_attach })
vim.lsp.enable('clangd')

-- formatting
require("conform").setup({
    formatters_by_ft = { python = { "isort", "black" }, lua = { "stylua" } },
    format_on_save = function(bufnr)
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then return end
        return { lsp_fallback = true }
    end,
})
vim.api.nvim_create_user_command("FormatToggle", function()
    vim.g.disable_autoformat = not vim.g.disable_autoformat
    print("Autoformat: " .. (vim.g.disable_autoformat and "OFF" or "ON"))
end, {})

-- diagnostics UI (no inline text)
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

-- prefer .venv python if present
local function prefer_project_venv()
    local venv = vim.fn.finddir('.venv', vim.fn.getcwd() .. ';')
    if venv ~= '' then
        local python = vim.fn.fnamemodify(venv, ":p") .. "bin/python"
        if vim.fn.executable(python) == 1 then vim.g.python3_host_prog = python end
    end
end
prefer_project_venv()

-- CUSTOM REMAPS
local map = vim.keymap.set
-- copy
map("n", "<leader>pv", vim.cmd.Ex)
map({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to system clipboard" })
map("n", "<leader>Y", [["+Y]], { desc = "Yank line to system clipboard" })
map("n", "<Esc>u", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })
map("x", "<leader>p", "\"_dP")
-- move
map("v", "K", ":m '<-2<CR>gv=gv")
map("v", "J", ":m '>+1<CR>gv=gv")
-- terminal
map("n", "<leader>tt", "<cmd>ToggleTerm direction=float<CR>", { desc = "Toggle terminal (float)" })
map("n", "<leader>th", "<cmd>ToggleTerm direction=horizontal size=12<CR>", { desc = "Terminal horizontal" })
map("n", "<leader>tv", "<cmd>ToggleTerm direction=vertical size=80<CR>", { desc = "Terminal vertical" })
-- lazygit
-- -- LazyGit integration with ToggleTerm
local Terminal = require("toggleterm.terminal").Terminal
local lazygit_term -- singleton

-- Check if we are inside a Git repository
local function in_git_repo()
    local ok = vim.fn.systemlist("git rev-parse --is-inside-work-tree")[1]
    return ok == "true"
end

-- Toggle LazyGit in a floating terminal
local function toggle_lazygit()
    if vim.fn.executable("lazygit") == 0 then
        vim.notify("`lazygit` not found in PATH. Please install it and try again.", vim.log.levels.ERROR)
        return
    end
    if not in_git_repo() then
        vim.notify("Not inside a Git repository (missing .git).", vim.log.levels.WARN)
        return
    end
    if not lazygit_term then
        lazygit_term = Terminal:new({
            cmd = "lazygit",
            direction = "float",
            hidden = true,
            dir = "git_dir", -- start at the repository root
        })
    end
    lazygit_term:toggle()
end

vim.keymap.set("n", "<leader>gg", toggle_lazygit, { desc = "LazyGit (float)" })
