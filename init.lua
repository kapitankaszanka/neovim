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
vim.g.maplocalleader = ","
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

vim.opt.list = true
vim.opt.listchars = {
    space = "·", -- kropka dla spacji
    tab = "→ ", -- strzałka dla tabów
    trail = "·", -- spacje na końcu linii
    extends = "›", -- linia za szeroka w prawo
    precedes = "‹", -- linia za szeroka w lewo
}

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
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons", "MunifTanjim/nui.nvim" },
    },
    { "akinsho/toggleterm.nvim", version = "*", config = true },
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
    snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
    mapping = cmp.mapping.preset.insert({
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
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
    sources = cmp.config.sources({ { name = "nvim_lsp" }, { name = "luasnip" } },
        { { name = "path" }, { name = "buffer" } }),
    formatting = { format = lspkind.cmp_format({ mode = "symbol_text", maxwidth = 50 }) },
})

-- LSP (Neovim 0.11+)
local mason = require("mason")
local mason_lsp = require("mason-lspconfig")
mason.setup()
mason_lsp.setup({ ensure_installed = { "basedpyright", "ruff", "lua_ls", "ansiblels", "gopls", "clangd" } })

local on_attach = function(_, bufnr)
    local nmap = function(keys, func, desc) vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc }) end
    nmap("gd", vim.lsp.buf.definition, "LSP: Goto Definition")
    nmap("gr", require("telescope.builtin").lsp_references, "LSP: References")
    nmap("K", vim.lsp.buf.hover, "LSP: Hover")
    nmap("<leader>rn", vim.lsp.buf.rename, "LSP: Rename")
    nmap("<leader>ca", vim.lsp.buf.code_action, "LSP: Code Action")
    nmap("[d", vim.diagnostic.goto_prev, "LSP: Prev diagnostic")
    nmap("]d", vim.diagnostic.goto_next, "LSP: Next diagnostic")
    nmap("<leader>fd", function() vim.lsp.buf.format({ async = true }) end, "LSP: Format buffer")
end
local capabilities = require("cmp_nvim_lsp").default_capabilities()

vim.lsp.config('basedpyright', {
    capabilities = capabilities,
    on_attach = on_attach,
    settings = { basedpyright = { analysis = { autoImportCompletions = true, useLibraryCodeForTypes = true, diagnosticMode = "openFilesOnly" } } }
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

vim.lsp.config('ansiblels', {
    on_attach = on_attach,
    capabilities = capabilities,
})
vim.lsp.enable('ansiblels')

vim.lsp.config('gopls', {
    on_attach = on_attach,
    capabilities = capabilities,
})
vim.lsp.enable('gopls')

vim.lsp.config('clangd', {
    on_attach = on_attach,
    capabilities = capabilities,
})
vim.lsp.enable('clangd')


-- conform (format on save)
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

-- diagnostics UI
vim.diagnostic.config({ virtual_text = { spacing = 2, prefix = "●" }, float = { border = "rounded" } })

--- mappings
-- copy
local map = vim.keymap.set
map({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to system clipboard" })
map("n", "<leader>Y", [["+Y]], { desc = "Yank line to system clipboard" })
map("n", "<leader>p", [["+p]], { desc = "Paste from system clipboard" })
map("n", "<Esc>u", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- hjkl with count-aware centering (centers once after the move)
local function with_zz(key)
    return function()
        local c = vim.v.count1
        return (c > 1 and tostring(c) or "") .. key .. "zz"
    end
end
map("n", "h", with_zz("h"), { expr = true, desc = "Left + center" })
map("n", "j", with_zz("j"), { expr = true, desc = "Down + center" })
map("n", "k", with_zz("k"), { expr = true, desc = "Up + center" })
map("n", "l", with_zz("l"), { expr = true, desc = "Right + center" })

-- search motions
map("n", "n", "nzzzv", { desc = "Next search result centered" })
map("n", "N", "Nzzzv", { desc = "Prev search result centered" })
map("n", "*", "*zzzv", { desc = "Search word forward centered" })
map("n", "#", "#zzzv", { desc = "Search word backward centered" })
map("n", "g*", "g*zzzv", { desc = "Search partial word forward centered" })
map("n", "g#", "g#zzzv", { desc = "Search partial word backward centered" })

-- file motions
map("n", "gg", "ggzz", { desc = "Top of file centered" })
map("n", "G", "Gzz", { desc = "Bottom of file centered" })

-- paragraph motions
map("n", "{", "{zz", { desc = "Prev paragraph centered" })
map("n", "}", "}zz", { desc = "Next paragraph centered" })

-- section/function motions
map("n", "[[", "[[zz", { desc = "Prev section centered" })
map("n", "]]", "]]zz", { desc = "Next section centered" })
map("n", "[]", "[]zz", { desc = "Prev function centered" })
map("n", "][", "][zz", { desc = "Next function centered" })

-- prefer .venv python if present
local function prefer_project_venv()
    local venv = vim.fn.finddir('.venv', vim.fn.getcwd() .. ';')
    if venv ~= '' then
        local python = vim.fn.fnamemodify(venv, ":p") .. "bin/python"
        if vim.fn.executable(python) == 1 then vim.g.python3_host_prog = python end
    end
end
prefer_project_venv()

-- which-key groups
local wk = require("which-key")
wk.add({
    { "<leader>f", group = "Find" },
    { "<leader>g", group = "Git" },
    { "<leader>t", group = "Terminal" },
    { "<leader>e", "<cmd>Neotree toggle filesystem left<CR>", desc = "File Explorer" },
})

-- neo-tree
require("neo-tree").setup({
    filesystem = {
        filtered_items = { hide_dotfiles = false, hide_gitignored = false },
    },
    window = { width = 30, position = "left" },
})

-- terminal / lazygit
map("n", "<leader>`", "<cmd>ToggleTerm direction=float<CR>", { desc = "Toggle terminal (float)" })
map("n", "<leader>tt", "<cmd>ToggleTerm<CR>", { desc = "Terminal" })
map("n", "<leader>th", "<cmd>ToggleTerm direction=horizontal size=12<CR>", { desc = "Terminal horizontal" })
map("n", "<leader>tv", "<cmd>ToggleTerm direction=vertical size=80<CR>", { desc = "Terminal vertical" })
map("n", "<leader>gg", function()
    require("toggleterm.terminal").Terminal:new({ cmd = "lazygit", direction = "float", hidden = true }):toggle()
end, { desc = "LazyGit" })
map("n", "<leader>gs", "<cmd>Telescope git_status<CR>", { desc = "Git status" })
map("n", "<leader>gb", "<cmd>Telescope git_branches<CR>", { desc = "Git branches" })
map("n", "<leader>gc", "<cmd>Telescope git_commits<CR>", { desc = "Git commits" })
