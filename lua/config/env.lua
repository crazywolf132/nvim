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
  "braydens-macbook-pro",
}

local function matches_any(host, patterns)
  for _, pattern in ipairs(patterns) do
    if host == pattern or host:find(pattern, 1, true) then
      return true
    end
  end
  return false
end

function M.uses_supermaven()
  return matches_any(M.hostname, M.supermaven_hosts)
end

return M
