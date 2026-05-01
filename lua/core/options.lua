-- lua/core/options.lua

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
vim.opt.colorcolumn    = "89"
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

-- prefer project-local Python venv if present
local function prefer_project_venv()
    local venv = vim.fn.finddir('.venv', vim.fn.getcwd() .. ';')
    if venv ~= '' then
        local python = vim.fn.fnamemodify(venv, ":p") .. "bin/python"
        if vim.fn.executable(python) == 1 then vim.g.python3_host_prog = python end
    end
end
prefer_project_venv()

-- LSP utility (fixing offset encoding)
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
