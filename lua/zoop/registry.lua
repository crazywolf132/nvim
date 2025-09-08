local M = {}

local store = {}

function M.add(spec)
  store[spec.name] = spec
end

function M.all()
  local out = {}
  for _, s in pairs(store) do table.insert(out, s) end
  table.sort(out, function(a,b) return a.name < b.name end)
  return out
end

function M.get(name)
  return store[name]
end

function M.clear()
  for k,_ in pairs(store) do store[k] = nil end
end

return M

