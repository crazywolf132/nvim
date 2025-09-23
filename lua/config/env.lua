local M = {}

local function current_hostname()
  local uname = vim.loop.os_uname() or {}
  local name = uname.nodename
  if not name or name == "" then
    local ok, host = pcall(vim.fn.hostname)
    if ok then
      name = host
    end
  end
  return (name or ""):lower()
end

M.hostname = current_hostname()
M.supermaven_hosts = {
  ["braydens-macbook-pro.local"] = true,
}

function M.uses_supermaven()
  return M.supermaven_hosts[M.hostname] or false
end

return M
