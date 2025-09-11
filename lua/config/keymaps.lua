local map = vim.keymap.set
local silent = { silent = true }

-- Better defaults
map({ "n", "v" }, "<Space>", "<Nop>", { silent = true })
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search", silent = true })

-- Save
map({ "n", "i", "v" }, "<C-s>", function()
  vim.cmd.update({ mods = { silent = true } })
end, { desc = "Save file" })

-- Windows
map("n", "<leader>wc", "<C-w>c", { desc = "Close window" })
map("n", "<leader>ws", "<C-w>s", { desc = "Split below" })
map("n", "<leader>wv", "<C-w>v", { desc = "Split right" })

-- Movement
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })

-- Telescope (lazy-loaded via command)
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Grep" })
map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Buffers" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Help tags" })
map("n", "<leader>fr", "<cmd>Telescope resume<cr>", { desc = "Resume picker" })
map("n", "<leader>fd", "<cmd>Telescope diagnostics bufnr=0<cr>", { desc = "Buffer diagnostics" })

-- File explorer (oil)
map("n", "-", "<cmd>Oil<cr>", { desc = "Open parent directory" })

-- Formatting (Conform)
map("n", "<leader>f", function()
  require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "Format buffer" })

-- Diagnostics
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
map("n", "<leader>ld", vim.diagnostic.open_float, { desc = "Line diagnostics" })

