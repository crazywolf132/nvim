local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

local yank_group = augroup("HighlightYank", { clear = true })
autocmd("TextYankPost", {
  group = yank_group,
  callback = function()
    vim.highlight.on_yank()
  end,
})

local biome_group = augroup("BiomeFormat", { clear = true })
autocmd("BufWritePre", {
  group = biome_group,
  pattern = { "*.ts", "*.tsx", "*.mts", "*.cts", "*.js", "*.jsx", "*.mjs", "*.cjs" },
  callback = function(event)
    local ok, formatting = pcall(require, "config.formatting")
    if not ok then
      vim.notify("Failed to load formatting helpers", vim.log.levels.ERROR, { title = "Biome" })
      return
    end
    formatting.maybe_format_with_biome(event.buf)
  end,
})

autocmd("BufReadPost", {
  desc = "Restore cursor position when reopening buffers",
  callback = function(event)
    local mark = vim.api.nvim_buf_get_mark(event.buf, '"')
    local lcount = vim.api.nvim_buf_line_count(event.buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})
