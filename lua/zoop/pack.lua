local M = {}

local has_pack = (vim.pack and type(vim.pack.add) == 'function')

---Explicitly packadd an optional plugin.
---@param name string
function M.packadd(name)
  if vim.fn.exists(':packadd') == 2 then
    vim.cmd('packadd ' .. name)
  end
end

function M.has_pack()
  return has_pack
end

return M
