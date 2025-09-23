local M = {}

local function highlight_hex(name, fallback)
  local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
  if not ok or not hl then return fallback end
  local color = hl.fg or hl.foreground
  if not color then return fallback end
  return string.format("#%06x", color)
end

local colors = {
  bg = highlight_hex("StatusLine", "#1c1a24"),
  fg = highlight_hex("StatusLine", "#e0def4"),
  accent1 = highlight_hex("DiffChange", "#f5a97f"),
  accent2 = highlight_hex("DiffAdd", "#a6da95"),
  accent3 = highlight_hex("DiffDelete", "#ed8796"),
  accent4 = highlight_hex("Constant", "#cba6f7"),
  accent5 = highlight_hex("Function", "#89b4fa"),
  accent6 = highlight_hex("DiagnosticWarn", "#f9e2af"),
  accent7 = highlight_hex("DiagnosticHint", "#94e2d5"),
  dim = highlight_hex("Comment", "#6c7086"),
}

local mode_colors = {
  n = { bg = colors.accent5, fg = colors.bg },
  i = { bg = colors.accent2, fg = colors.bg },
  v = { bg = colors.accent4, fg = colors.bg },
  V = { bg = colors.accent4, fg = colors.bg },
  ["\22"] = { bg = colors.accent4, fg = colors.bg },
  c = { bg = colors.accent1, fg = colors.bg },
  s = { bg = colors.accent6, fg = colors.bg },
  S = { bg = colors.accent6, fg = colors.bg },
  ["\19"] = { bg = colors.accent6, fg = colors.bg },
  R = { bg = colors.accent3, fg = colors.bg },
  r = { bg = colors.accent3, fg = colors.bg },
  ["r?"] = { bg = colors.accent3, fg = colors.bg },
  t = { bg = colors.accent5, fg = colors.bg },
}

local separators = {
  right = "▓▒░",
  left = "░▒▓",
}

local conditions = {
  buffer_not_empty = function()
    return vim.fn.empty(vim.fn.expand("%:t")) ~= 1
  end,
  hide_in_width_first = function()
    return vim.fn.winwidth(0) > 80
  end,
  hide_in_width = function()
    return vim.fn.winwidth(0) > 70
  end,
  check_git_workspace = function()
    local filepath = vim.fn.expand("%:p:h")
    local gitdir = vim.fn.finddir(".git", filepath .. ";")
    return gitdir ~= "" and gitdir ~= nil and #gitdir > 0 and #gitdir < #filepath
  end,
}

local function current_mode_color()
  local mode = vim.fn.mode()
  return mode_colors[mode] or { bg = colors.accent5, fg = colors.bg }
end

local function dump_table(items)
  if type(items) ~= "table" then
    return tostring(items)
  end
  local result = {}
  for _, value in ipairs(items) do
    result[#result + 1] = tostring(value)
  end
  return table.concat(result, ",")
end

local function supermaven_state()
  local ok, api = pcall(require, "supermaven-nvim.api")
  if ok then
    local status_ok, running = pcall(api.is_running)
    if status_ok then
      return true, running
    end
    return true, false
  end
  if vim.g.SUPERMAVEN_DISABLED ~= nil then
    return true, vim.g.SUPERMAVEN_DISABLED == 0
  end
  return false, false
end

local function supermaven_component()
  return " AI"
  -- local available, running = supermaven_state()
  -- if not available then return "" end
  -- if running then
  --   return " AI"
  -- end
  -- return "AI off"
end

local function supermaven_color()
  local available, running = supermaven_state()
  if not available then
    return { bg = colors.dim, fg = colors.bg }
  end
  if running then
    return { bg = colors.accent7, fg = colors.bg }
  end
  return { bg = colors.dim, fg = colors.bg }
end

local function build_config()
  local config = {
    options = {
      component_separators = "",
      section_separators = "",
      theme = {
        normal = { c = { fg = colors.fg, bg = colors.bg } },
        inactive = { c = { fg = colors.fg, bg = colors.bg } },
      },
    },
    sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = {},
      lualine_x = {},
      lualine_y = {},
      lualine_z = {},
    },
    inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = {},
      lualine_x = {},
      lualine_y = {},
      lualine_z = {},
    },
  }

  local function active_left(component)
    table.insert(config.sections.lualine_c, component)
  end

  local function inactive_left(component)
    table.insert(config.inactive_sections.lualine_c, component)
  end

  local function active_right(component)
    table.insert(config.sections.lualine_x, component)
  end

  local function inactive_right(component)
    table.insert(config.inactive_sections.lualine_x, component)
  end

  -- Active left: icon
  active_left({
    function()
      local icon
      local ok, devicons = pcall(require, "nvim-web-devicons")
      if ok then
        icon = devicons.get_icon(vim.fn.expand("%:t"))
        if icon == nil then
          icon = devicons.get_icon_by_filetype(vim.bo.filetype)
        end
      end
      if not icon and vim.fn.exists("*WebDevIconsGetFileTypeSymbol") > 0 then
        icon = vim.fn.WebDevIconsGetFileTypeSymbol()
      end
      if not icon then
        icon = ""
      end
      return icon:gsub("%s+", "")
    end,
    color = current_mode_color,
    padding = { left = 1, right = 1 },
    separator = { right = separators.right },
  })

  -- Active left: filename
  active_left({
    "filename",
    cond = conditions.buffer_not_empty,
    color = current_mode_color,
    padding = { left = 1, right = 1 },
    separator = { right = separators.right },
    symbols = {
      modified = "󰶻 ",
      readonly = " ",
      unnamed = " ",
      newfile = " ",
    },
  })

  -- Active left: branch
  active_left({
    "branch",
    icon = "",
    cond = conditions.check_git_workspace,
    color = { bg = colors.accent1, fg = colors.bg },
    padding = { left = 0, right = 1 },
    separator = { left = separators.left, right = separators.right },
  })

  -- Inactive left icon
  inactive_left({
    function()
      return ""
    end,
    cond = conditions.buffer_not_empty,
    color = { bg = colors.dim, fg = colors.bg },
    padding = { left = 1, right = 1 },
  })

  inactive_left({
    "filename",
    cond = conditions.buffer_not_empty,
    color = { bg = colors.dim, fg = colors.bg },
    padding = { left = 1, right = 1 },
    separator = { right = separators.right },
    symbols = {
      modified = "",
      readonly = "",
      unnamed = "",
      newfile = "",
    },
  })

  -- Active right: LSP clients
  active_right({
    function()
      if not vim.lsp.get_clients then return "" end
      local clients = vim.lsp.get_clients({ bufnr = 0 })
      local names = {}
      local seen = {}
      for _, client in ipairs(clients) do
        local raw_name = client.name or ""
        if not raw_name:lower():find("copilot") and not seen[raw_name] then
          names[#names + 1] = raw_name
          seen[raw_name] = true
        end
      end
      if vim.tbl_isempty(names) then return "" end
      table.sort(names)
      local label = dump_table(names):gsub(",", ", ")
      return label
    end,
    icon = " ",
    color = { bg = colors.accent5, fg = colors.bg },
    padding = { left = 1, right = 1 },
    cond = conditions.hide_in_width_first,
    separator = { left = separators.left, right = separators.right },
  })

  -- Active right: AI status
  active_right({
    supermaven_component,
    cond = function()
      local available = select(1, supermaven_state())
      return available
    end,
    color = supermaven_color,
    padding = { left = 1, right = 1 },
    separator = { right = separators.right, left = separators.left },
  })

  -- Active right: diagnostics
  active_right({
    "diagnostics",
    sources = { "nvim_diagnostic" },
    symbols = { error = " ", warn = " ", info = " " },
    diagnostics_color = {
      error = { fg = colors.bg },
      warn = { fg = colors.bg },
      info = { fg = colors.bg },
    },
    color = { bg = colors.accent6, fg = colors.bg },
    padding = { left = 1, right = 1 },
    separator = { left = separators.left, right = separators.right },
  })

  -- Active right: searchcount
  active_right({
    "searchcount",
    color = { bg = colors.accent2, fg = colors.bg },
    padding = { left = 1, right = 1 },
    separator = { left = separators.left, right = separators.right },
  })

  -- Active right: location
  active_right({
    "location",
    color = { bg = colors.accent4, fg = colors.bg },
    padding = { left = 1, right = 0 },
    separator = { left = separators.left },
  })

  -- Active right: progress percentage
  active_right({
    function()
      local cur = vim.fn.line(".")
      local total = vim.fn.line("$")
      if total == 0 then return " 0%%" end
      return string.format("%2d%%%%", math.floor(cur / total * 100))
    end,
    color = { bg = colors.accent4, fg = colors.bg },
    padding = { left = 1, right = 1 },
    cond = conditions.hide_in_width,
    separator = { right = separators.right },
  })

  -- Active right: branch badge
  active_right({
    function()
      local branch = vim.b.gitsigns_head or ""
      if branch == "" then return "" end
      return " " .. branch
    end,
    cond = conditions.check_git_workspace,
    color = { bg = colors.accent1, fg = colors.bg },
    padding = { left = 1, right = 1 },
    separator = { right = separators.right },
  })

  -- Inactive right components
  inactive_right({
    "location",
    color = { bg = colors.dim, fg = colors.bg },
    padding = { left = 1, right = 0 },
    separator = { left = separators.left },
  })

  inactive_right({
    "progress",
    color = { bg = colors.dim, fg = colors.bg },
    cond = conditions.hide_in_width,
    padding = { left = 1, right = 1 },
    separator = { right = separators.right },
  })

  inactive_right({
    "fileformat",
    fmt = string.lower,
    icons_enabled = false,
    cond = conditions.hide_in_width,
    color = { bg = colors.dim, fg = colors.bg },
    separator = { right = separators.right },
    padding = { left = 0, right = 1 },
  })

  return config
end

function M.init()
  vim.opt.laststatus = 0
end

function M.opts()
  return build_config()
end

function M.post_setup()
  vim.opt.laststatus = 3
  local group = vim.api.nvim_create_augroup("CodexLualineRefresh", { clear = true })
  vim.api.nvim_create_autocmd({
    "RecordingEnter",
    "RecordingLeave",
    "DiagnosticChanged",
    "LspAttach",
    "LspDetach",
    "BufEnter",
    "BufWritePost",
  }, {
    group = group,
    callback = function()
      vim.schedule(function()
        local ok, lualine = pcall(require, "lualine")
        if not ok or type(lualine.refresh) ~= "function" then return end
        local refreshed = pcall(lualine.refresh, {
          scope = "tabpage",
          place = { "statusline" },
        })
        if not refreshed then
          pcall(vim.cmd, "redrawstatus")
        end
      end)
    end,
  })
end

return M
