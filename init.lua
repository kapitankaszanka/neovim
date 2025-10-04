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
vim.g.mapleader        = " "
vim.opt.number         = true
vim.opt.relativenumber = true
vim.opt.mouse          = "a"
vim.opt.ignorecase     = true
vim.opt.smartcase      = true
vim.opt.termguicolors  = true
vim.opt.updatetime     = 200
vim.opt.signcolumn     = "yes"
vim.opt.expandtab      = true
vim.opt.shiftwidth     = 4
vim.opt.tabstop        = 4
vim.opt.colorcolumn    = "80"
vim.opt.swapfile       = false
vim.opt.backup         = false
vim.opt.writebackup    = false
vim.opt.list           = true
vim.opt.listchars      = {
    space = "·",
    tab = "→ ",
    trail = "·",
    extends = "›",
    precedes = "‹"
}

do
    local function buf_clients(bufnr)
        bufnr = bufnr or 0
        if vim.lsp.get_clients then
            return vim.lsp.get_clients({ bufnr = bufnr })
        else
            return vim.lsp.get_active_clients({ bufnr = bufnr })
        end
    end

    local util = vim.lsp.util
    if util and type(util.make_position_params) == "function" then
        local old = util.make_position_params
        util.make_position_params = function(bufnr, encoding)
            bufnr = bufnr or 0
            if not encoding then
                for _, c in ipairs(buf_clients(bufnr)) do
                    if c and c.offset_encoding then
                        encoding = c.offset_encoding
                        break
                    end
                end
                encoding = encoding or "utf-16"
            end
            return old(bufnr, encoding)
        end
    end
end

-- folding settings
vim.o.foldcolumn     = "1" -- gutter with fold markers
vim.o.foldlevel      = 99  -- open everything by default
vim.o.foldlevelstart = 99
vim.o.foldenable     = true
vim.o.foldmethod     = "expr"
vim.o.foldexpr       = "nvim_treesitter#foldexpr()"

-- split
vim.opt.splitright   = true
vim.opt.splitbelow   = true

-- TABLINE (real Vim tabs)
vim.opt.showtabline  = 2 -- always show the tabline; default shows numbers 1..N
-- Alt+1..Alt+9 -> go to specific tab; Alt+0 -> last tab
for i = 1, 9 do
    vim.keymap.set("n", "<M-" .. i .. ">", function() vim.cmd("tabnext " .. i) end,
        { desc = "Tab " .. i })
end
vim.keymap.set("n", "<M-0>", "<cmd>tablast<CR>", { desc = "Last tab" })
-- Handy tab management shortcuts
vim.keymap.set("n", "<leader>tn", "<cmd>tabnew<CR>", { desc = "New tab" })
vim.keymap.set("n", "<leader>to", "<cmd>tabonly<CR>", { desc = "Close other tabs" })
vim.keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" })
vim.keymap.set("n", "<leader>ts", "<cmd>tab split<CR>", { desc = "Current window to new tab" })
vim.keymap.set("n", "<leader>tH", "<cmd>tabmove -1<CR>", { desc = "Move tab left" })
vim.keymap.set("n", "<leader>tL", "<cmd>tabmove +1<CR>", { desc = "Move tab right" })

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
    { "nvim-telescope/telescope.nvim" },
    { "lewis6991/gitsigns.nvim",      config = true },
    {
        "nvim-lualine/lualine.nvim",
        config = function()
            -- lualine statusline (tabline is native and already shows numbers)
            require("lualine").setup({ options = { theme = "tokyonight" } })
        end
    },
    { "folke/which-key.nvim",             event = "VeryLazy", config = true },

    -- treesitter
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
                    "yaml"
                },
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
    { "L3MON4D3/LuaSnip",                 version = "v2.*",   build = "make install_jsregexp" },
    { "onsails/lspkind.nvim" },
    { "stevearc/conform.nvim" },
    { "akinsho/toggleterm.nvim",          version = "*",      config = true },

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

    { "kevinhwang91/promise-async" },
    {
        "kevinhwang91/nvim-ufo",
        event = "VeryLazy",
        dependencies = { "kevinhwang91/promise-async" },
        config = function()
            -- default: use treesitter, then indent
            require("ufo").setup({
                provider_selector = function(_, _, _)
                    return { "treesitter", "indent" }
                end,
                -- custom fold text
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
            -- shortcuts
            vim.keymap.set("n", "zR", require("ufo").openAllFolds, { desc = "Folds: open all" })
            vim.keymap.set("n", "zM", require("ufo").closeAllFolds, { desc = "Folds: close all" })

            -- peek folded lines (fallback to LSP hover)
            vim.keymap.set("n", "zp", function()
                local winid = require("ufo").peekFoldedLinesUnderCursor()
                if not winid then vim.lsp.buf.hover() end
            end, { desc = "Fold: peek (fallback hover)" })
        end,
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
    -- important: 'noselect' instead of 'noinsert'
    completion = { completeopt = "menu,menuone,noselect" },

    snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },

    mapping = cmp.mapping.preset.insert({
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),

        -- <CR>: only confirm if something is selected; otherwise newline
        ["<CR>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                local entry = cmp.get_selected_entry()
                if entry then
                    cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
                else
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
                typeCheckingMode = "standard",
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

vim.lsp.config('lua_ls', {
    capabilities = capabilities,
    on_attach = on_attach,
    settings = { Lua = { diagnostics = { globals = { "vim" } } } }
})
vim.lsp.enable('lua_ls')

vim.lsp.config('gopls', {
    capabilities = capabilities,
    on_attach = on_attach,
    settings = {
        gopls = {
            analyses = {
                unusedparams = true,
                shadow = true,
            },
            staticcheck = true,
        },
    },
})
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

-- prefer project-local Python venv if present
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
-- change mode
map("i", "jk", "<Esc>")
map("n", "<leader>pv", function() vim.cmd("tabnew | Ex") end)
-- copy
map({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to system clipboard" })
map("n", "<leader>Y", [["+Y]], { desc = "Yank line to system clipboard" })
map("n", "<Esc>u", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })
map("x", "<leader>p", "\"_dP")
-- move lines
map("v", "K", ":m '<-2<CR>gv=gv")
map("v", "J", ":m '>+1<CR>gv=gv")
map({ "v", "x" }, ">", ">gv", { desc = "Indent right (keep selection)" })
map({ "v", "x" }, "<", "<gv", { desc = "Indent left (keep selection)" })
-- terminal
map("t", "zx", [[<C-\><C-n>]], { desc = "Exit terminal mode" })
map("n", "<leader>tt", "<cmd>ToggleTerm direction=float<CR>", { desc = "Toggle terminal (float)" })
map("n", "<leader>th", "<cmd>ToggleTerm direction=horizontal size=12<CR>", { desc = "Terminal horizontal" })
map("n", "<leader>tv", "<cmd>ToggleTerm direction=vertical size=80<CR>", { desc = "Terminal vertical" })

-- lazygit via ToggleTerm
local Terminal = require("toggleterm.terminal").Terminal
local lazygit_term -- singleton

local function in_git_repo()
    local ok = vim.fn.systemlist("git rev-parse --is-inside-work-tree")[1]
    return ok == "true"
end

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
            dir = "git_dir",
        })
    end
    lazygit_term:toggle()
end

vim.keymap.set("n", "<leader>gg", toggle_lazygit, { desc = "LazyGit (float)" })
