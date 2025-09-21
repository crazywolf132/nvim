local M = {}

local function schemastore_loader(kind)
  local ok, schemastore = pcall(require, "schemastore")
  if not ok then
    return {}
  end
  if kind == "json" then
    return schemastore.json.schemas()
  elseif kind == "yaml" then
    return schemastore.yaml.schemas()
  end
  return {}
end

function M.json()
  return {
    json = {
      schemas = schemastore_loader("json"),
      validate = { enable = true },
    },
  }
end

function M.yaml()
  return {
    yaml = {
      schemaStore = { enable = false, url = "" },
      keyOrdering = false,
      schemas = schemastore_loader("yaml"),
    },
  }
end

return M
