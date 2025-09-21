local M = {}

local cached_capabilities

local function buf_map(bufnr, mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
end

function M.capabilities()
  if not cached_capabilities then
    cached_capabilities = require("blink.cmp").get_lsp_capabilities()
  end
  return cached_capabilities
end

function M.on_attach(client, bufnr)
  buf_map(bufnr, "n", "gd", vim.lsp.buf.definition, "Goto Definition")
  buf_map(bufnr, "n", "gD", vim.lsp.buf.declaration, "Goto Declaration")
  buf_map(bufnr, "n", "gi", vim.lsp.buf.implementation, "Goto Implementation")
  buf_map(bufnr, "n", "gr", vim.lsp.buf.references, "Goto References")
  buf_map(bufnr, "n", "K", vim.lsp.buf.hover, "Hover")
  buf_map(bufnr, "n", "<leader>rn", vim.lsp.buf.rename, "Rename")
  buf_map(bufnr, { "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code Action")
  buf_map(bufnr, "n", "<leader>lf", function()
    vim.lsp.buf.format({ async = true })
  end, "Format")

  if client.name == "typescript-tools" then
    buf_map(bufnr, "n", "<leader>to", "<cmd>TSToolsOrganizeImports<CR>", "TS Organize Imports")
    buf_map(bufnr, "n", "<leader>ta", "<cmd>TSToolsFixAll<CR>", "TS Fix All")
    buf_map(bufnr, "n", "<leader>tr", "<cmd>TSToolsRenameFile<CR>", "TS Rename File")
  end

  if client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
    if type(vim.lsp.inlay_hint) == "function" then
      vim.lsp.inlay_hint(bufnr, true)
    elseif type(vim.lsp.inlay_hint) == "table" and vim.lsp.inlay_hint.enable then
      vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    end
  end
end

return M
