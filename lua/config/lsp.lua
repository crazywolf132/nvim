local M = {}

local cached_capabilities

local function buf_map(bufnr, mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
end

function M.capabilities()
  if not cached_capabilities then
    local ok, blink = pcall(require, "blink.cmp")
    if ok and type(blink.get_lsp_capabilities) == "function" then
      cached_capabilities = blink.get_lsp_capabilities()
    else
      local base = vim.lsp.protocol.make_client_capabilities()
      local cmp_ok, cmp = pcall(require, "cmp_nvim_lsp")
      -- fall back to cmp_nvim_lsp if available, otherwise use base capabilities
      cached_capabilities = cmp_ok and cmp.default_capabilities and cmp.default_capabilities(base) or base
    end
  end
  return cached_capabilities
end

function M.on_attach(client, bufnr)
  local function open_code_actions()
    local ok, fzf = pcall(require, "fzf-lua")
    if ok and type(fzf.lsp_code_actions) == "function" then
      fzf.lsp_code_actions()
      return
    end
    vim.lsp.buf.code_action()
  end

  buf_map(bufnr, "n", "gd", vim.lsp.buf.definition, "Goto Definition")
  buf_map(bufnr, "n", "gD", vim.lsp.buf.declaration, "Goto Declaration")
  buf_map(bufnr, "n", "gi", vim.lsp.buf.implementation, "Goto Implementation")
  buf_map(bufnr, "n", "gr", vim.lsp.buf.references, "Goto References")
  buf_map(bufnr, "n", "K", vim.lsp.buf.hover, "Hover")
  buf_map(bufnr, "n", "<leader>rn", vim.lsp.buf.rename, "Rename")
  buf_map(bufnr, { "n", "v" }, "<leader>ca", open_code_actions, "Code Action")
  buf_map(bufnr, { "n", "v" }, "<leader>.", open_code_actions, "Quick Fix")
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
    pcall(vim.api.nvim_buf_set_var, bufnr, "inlay_hints_enabled", true)
  end
end

function M.toggle_inlay_hints(bufnr)
  local inlay_hint = vim.lsp.inlay_hint
  if not inlay_hint then
    vim.notify("Inlay hints are not supported in this version of Neovim", vim.log.levels.WARN, { title = "LSP" })
    return
  end

  bufnr = bufnr or vim.api.nvim_get_current_buf()

  local function current_state()
    local ok, value = pcall(vim.api.nvim_buf_get_var, bufnr, "inlay_hints_enabled")
    if ok then
      return value
    end
    if type(inlay_hint) == "table" and inlay_hint.is_enabled then
      return inlay_hint.is_enabled({ bufnr = bufnr })
    end
    return false
  end

  local new_state = not current_state()

  if type(inlay_hint) == "function" then
    inlay_hint(bufnr, new_state)
  elseif type(inlay_hint) == "table" and inlay_hint.enable then
    inlay_hint.enable(new_state, { bufnr = bufnr })
  else
    return
  end

  pcall(vim.api.nvim_buf_set_var, bufnr, "inlay_hints_enabled", new_state)
end

return M
