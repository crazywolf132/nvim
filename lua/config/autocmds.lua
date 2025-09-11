local aug = vim.api.nvim_create_augroup
local auc = vim.api.nvim_create_autocmd

-- Highlight on yank
auc("TextYankPost", {
  group = aug("YankHighlight", { clear = true }),
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 150 })
  end,
})

-- Make q close common transient windows
auc("FileType", {
  group = aug("QuickClose", { clear = true }),
  pattern = {
    "help",
    "qf",
    "lspinfo",
    "man",
    "checkhealth",
    "oil",
    "mason",
    "lazy",
  },
  callback = function(ev)
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = ev.buf, silent = true })
  end,
})

-- Resize splits when the window is resized
auc("VimResized", {
  group = aug("ResizeSplits", { clear = true }),
  command = "wincmd =",
})

