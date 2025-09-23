local M = {}

local biome_config_files = { "biome.json", "biome.jsonc", ".biome.json", ".biome.jsonc" }

local function get_buf_path(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == "" then
    return nil
  end
  return name
end

local function find_biome_config(bufnr)
  local path = get_buf_path(bufnr)
  if not path then
    return nil
  end

  local dir = vim.fs.dirname(path)
  if not dir then
    return nil
  end

  return vim.fs.find(biome_config_files, { path = dir, upward = true })[1]
end

local function run_biome(bufnr, input)
  local filepath = get_buf_path(bufnr)
  if not filepath then
    return nil, "No file path"
  end

  local args = { "biome", "format", "--stdin-file-path", filepath }

  if vim.system then
    local result = vim.system(args, { stdin = input, text = true }):wait()
    if not result then
      return nil, "Failed to run biome"
    end
    if result.code ~= 0 then
      local stderr = result.stderr or ""
      return nil, stderr ~= "" and stderr or string.format("biome exited with code %d", result.code)
    end
    return result.stdout, nil
  end

  local cmd = table.concat(args, " ")
  local output = vim.fn.system(cmd, input)
  if vim.v.shell_error ~= 0 then
    return nil, output ~= "" and output or string.format("biome exited with code %d", vim.v.shell_error)
  end
  return output, nil
end

local function sanitize_output(output)
  if not output then
    return nil
  end

  output = output:gsub("\r\n", "\n")

  local lines = vim.split(output, "\n", { plain = true })
  if lines[#lines] == "" then
    table.remove(lines, #lines)
  end

  return lines
end

function M.maybe_format_with_biome(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  if not find_biome_config(bufnr) then
    return false
  end

  if vim.fn.executable("biome") == 0 then
    vim.notify("Biome config detected but 'biome' executable is not available", vim.log.levels.WARN, { title = "Biome" })
    return false
  end

  local current_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local input = table.concat(current_lines, "\n") .. "\n"

  local output, err = run_biome(bufnr, input)
  if not output then
    vim.notify("Biome format failed: " .. err, vim.log.levels.ERROR, { title = "Biome" })
    return false
  end

  local formatted_lines = sanitize_output(output)
  if not formatted_lines then
    return false
  end

  if vim.deep_equal(current_lines, formatted_lines) then
    return true
  end

  local view = vim.fn.winsaveview()
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, formatted_lines)
  vim.fn.winrestview(view)

  return true
end

return M
