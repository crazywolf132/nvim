local M = {}

local leader_groups = {
  { "<leader>b", group = "Buffers" },
  { "<leader>g", group = "Git & GitHub" },
  { "<leader>q", group = "Quit" },
  { "<leader>s", group = "Splits" },
  { "<leader>t", group = "Toggles" },
  { "<leader>w", group = "Write" },
  { "<leader>?", group = "Help" },
  { "<leader>/", desc = "Live Grep" },
  { "<leader>|", desc = "Vertical Split" },
  { "<leader>`", desc = "Alternate Buffer" },
  { "<leader>h", desc = "Clear Highlight" },
  { "<leader>ai", desc = "Toggle AI Assistant" },
  { "<leader>bd", desc = "Close Buffer" },
  { "<leader>bb", desc = "Buffer Manager" },
  { "<leader>sv", desc = "Split Right" },
  { "<leader>sh", desc = "Split Below" },
  { "<leader>gg", desc = "Lazygit" },
  { "<leader>gb", desc = "Git Blame Line" },
  { "<leader>go", desc = "Octo actions" },
  { "<leader>gi", desc = "List Issues" },
  { "<leader>gp", desc = "List Pull Requests" },
  { "<leader>gN", desc = "New Issue" },
  { "<leader>gn", desc = "Notifications" },
  { "<leader>ps", desc = "Open Store" },
  { "<leader>tw", desc = "Toggle Twilight" },
  { "<leader>tb", desc = "Toggle word/boolean" },
  { "<leader>u", desc = "Toggle Undotree" },
  { "<leader>vd", desc = "Toggle venn mode" },
  { "<leader>vb", desc = "Draw venn box" },
  { "gl", desc = "Line Diagnostics" },
}

function M.setup()
  local wk = require("which-key")
  wk.setup({
    notify = false,
    plugins = {
      marks = false,
      registers = false,
    },
    win = {
      border = "rounded",
    },
  })
  wk.add(leader_groups)
end

return M
