local M = {}

local normal_mappings = {
  J = "<C-v>j:VBox<CR>",
  K = "<C-v>k:VBox<CR>",
  H = "<C-v>h:VBox<CR>",
  L = "<C-v>l:VBox<CR>",
}

---Toggle venn drawing helpers for the current buffer.
function M.toggle()
  require("venn")

  local buf = vim.api.nvim_get_current_buf()
  local is_enabled = vim.b.venn_enabled

  if is_enabled then
    vim.cmd("setlocal ve=")
    for key in pairs(normal_mappings) do
      pcall(vim.keymap.del, "n", key, { buffer = buf })
    end
    pcall(vim.keymap.del, "v", "f", { buffer = buf })
    vim.b.venn_enabled = nil
    return
  end

  vim.b.venn_enabled = true
  vim.cmd("setlocal ve=all")

  local map_opts = { buffer = buf, noremap = true, silent = true }
  for key, mapping in pairs(normal_mappings) do
    vim.keymap.set("n", key, mapping, map_opts)
  end
  vim.keymap.set("v", "f", ":VBox<CR>", map_opts)
end

---Draw a venn box/line for the current visual selection.
function M.draw_box()
  require("venn")
  vim.cmd("VBox")
end

return M
