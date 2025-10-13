local M = {}

local cached_capabilities
local format_augroup = vim.api.nvim_create_augroup("LspFormatOnSave", {})

local function buf_map(bufnr, mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
end

function M.capabilities()
  if not cached_capabilities then
    local ok, blink = pcall(require, "blink.cmp")
    if ok and type(blink.get_lsp_capabilities) == "function" then
      cached_capabilities = blink.get_lsp_capabilities()
    else
      cached_capabilities = vim.lsp.protocol.make_client_capabilities()
    end
  end
  return cached_capabilities
end

function M.on_attach(client, bufnr)
  local ok, already = pcall(vim.api.nvim_buf_get_var, bufnr, "lsp_keymaps_set")
  if ok and already then
    return
  end

  buf_map(bufnr, "n", "gd", vim.lsp.buf.definition, "Goto Definition")
  buf_map(bufnr, "n", "gD", vim.lsp.buf.declaration, "Goto Declaration")
  buf_map(bufnr, "n", "gr", vim.lsp.buf.references, "Goto References")
  buf_map(bufnr, "n", "gi", vim.lsp.buf.implementation, "Goto Implementation")
  buf_map(bufnr, "n", "K", vim.lsp.buf.hover, "Hover")
  buf_map(bufnr, "n", "<leader>rn", vim.lsp.buf.rename, "Rename")
  buf_map(bufnr, { "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code Action")
  buf_map(bufnr, { "n", "v" }, "<leader>lf", function()
    vim.lsp.buf.format({ async = true })
  end, "Format")

  if client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
    M.toggle_inlay_hints(bufnr, true)
  end

  vim.api.nvim_clear_autocmds({ group = format_augroup, buffer = bufnr })
  vim.api.nvim_create_autocmd("BufWritePre", {
    group = format_augroup,
    buffer = bufnr,
    callback = function()
      M.format_and_fix(bufnr)
    end,
  })

  pcall(vim.api.nvim_buf_set_var, bufnr, "lsp_keymaps_set", true)
end

function M.toggle_inlay_hints(bufnr, force_state)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  local inlay_hint = vim.lsp.inlay_hint
  if not inlay_hint then
    return
  end

  local function current_state()
    local ok, value = pcall(vim.api.nvim_buf_get_var, bufnr, "inlay_hints_enabled")
    if ok then
      return value
    end
    if type(inlay_hint) == "table" and type(inlay_hint.is_enabled) == "function" then
      return inlay_hint.is_enabled({ bufnr = bufnr })
    end
    return false
  end

  local new_state = force_state
  if new_state == nil then
    new_state = not current_state()
  end

  if type(inlay_hint) == "function" then
    pcall(inlay_hint, bufnr, new_state)
  elseif type(inlay_hint.enable) == "function" then
    pcall(inlay_hint.enable, new_state, { bufnr = bufnr })
  end

  pcall(vim.api.nvim_buf_set_var, bufnr, "inlay_hints_enabled", new_state)
end

local function supports_method(bufnr, method)
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  for _, client in ipairs(clients) do
    if client.supports_method(method) then
      return true
    end
  end
  return false
end

function M.apply_source_actions(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if not supports_method(bufnr, "textDocument/codeAction") then
    return
  end

  local params = vim.lsp.util.make_range_params()
  params.context = {
    diagnostics = vim.diagnostic.get(bufnr),
    only = { "source.fixAll", "source.organizeImports" },
  }

  local results = vim.lsp.buf_request_sync(bufnr, "textDocument/codeAction", params, 1500)
  if not results then
    return
  end

  for client_id, result in pairs(results) do
    local client = vim.lsp.get_client_by_id(client_id)
    if client then
      for _, action in ipairs(result.result or {}) do
        if action.edit then
          vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding or "utf-16")
        end

        local command = action.command
        if type(command) == "table" then
          client.request_sync("workspace/executeCommand", command, 1000)
        elseif type(command) == "string" then
          client.request_sync("workspace/executeCommand", {
            command = command,
            arguments = action.arguments,
          }, 1000)
        end
      end
    end
  end
end

function M.format_and_fix(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  M.apply_source_actions(bufnr)

  if supports_method(bufnr, "textDocument/formatting") then
    local ok, err = pcall(vim.lsp.buf.format, {
      bufnr = bufnr,
      timeout_ms = 2000,
    })
    if not ok then
      vim.notify(("LSP format failed: %s"):format(err), vim.log.levels.WARN, { title = "LSP" })
    end
  end
end

local autocmd_registered = false

function M.setup_autocmd()
  if autocmd_registered then
    return
  end

  autocmd_registered = true
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if not client then
        return
      end
      M.on_attach(client, args.buf)
    end,
  })
end

M.servers = {
  lua_ls = {
    settings = {
      Lua = {
        diagnostics = { globals = { "vim" } },
        workspace = { checkThirdParty = false },
      },
    },
  },
  rust_analyzer = {
    settings = {
      ["rust-analyzer"] = {
        cargo = {
          allFeatures = true,
          buildScripts = {
            enable = true,
          },
        },
        checkOnSave = { command = "clippy" },
        inlayHints = {
          bindingModeHints = { enable = true },
          lifetimeElisionHints = { enable = "skip_trivial" },
          closingBraceHints = { enable = false },
          parameterHints = { enable = true },
          typeHints = { enable = true },
        },
      },
    },
  },
  ts_ls = {},
  gopls = {},
  pyright = {},
  jsonls = {},
  yamlls = {},
  html = {},
  cssls = {},
  dockerls = {},
  eslint = {},
  emmet_language_server = {},
}

return M
