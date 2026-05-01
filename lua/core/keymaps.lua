-- lua/core/keymaps.lua

local map = vim.keymap.set

-- Alt+1..Alt+9 -> go to specific tab; Alt+0 -> last tab
for i = 1, 9 do
    map("n", "<M-" .. i .. ">", function() vim.cmd("tabnext " .. i) end,
        { desc = "Tab " .. i })
end
map("n", "<M-0>", "<cmd>tablast<CR>", { desc = "Last tab" })

-- Handy tab management shortcuts
map("n", "<leader>tn", "<cmd>tabnew<CR>", { desc = "New tab" })
map("n", "<leader>to", "<cmd>tabonly<CR>", { desc = "Close other tabs" })
map("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" })
map("n", "<leader>ts", "<cmd>tab split<CR>", { desc = "Current window to new tab" })
map("n", "<leader>tH", "<cmd>tabmove -1<CR>", { desc = "Move tab left" })
map("n", "<leader>tL", "<cmd>tabmove +1<CR>", { desc = "Move tab right" })

-- change mode
map("i", "jk", "<Esc>")
map("n", "<leader>pv", function() vim.cmd("Ex") end)

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
