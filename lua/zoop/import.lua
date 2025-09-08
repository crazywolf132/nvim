local M = {}

-- Minimal importer from lazy.nvim-style specs
-- Accepts a list of entries like { 'owner/repo', dependencies = {...}, build=..., event=..., cmd=..., keys=..., ft=..., opts=..., config=function() end }
-- Maps to zoop.add calls. Returns a list of zoop specs that were added.
function M.from_lazy(list)
  local added = {}
  local zoop = require('zoop')
  for _, e in ipairs(list or {}) do
    local spec = {}
    if type(e) == 'string' then
      spec[1] = e
    elseif type(e) == 'table' then
      if type(e[1]) == 'string' then spec[1] = e[1] end
      -- common fields
      spec.lazy = e.lazy or e.event ~= nil or e.ft ~= nil or e.cmd ~= nil or e.keys ~= nil
      spec.dependencies = e.dependencies or e.deps
      spec.build = e.build
      spec.event = e.event
      spec.cmd = e.cmd
      spec.keys = e.keys
      spec.ft = e.ft
      spec.main = e.main
      spec.opts = e.opts
      spec.config = e.config
      spec.init = e.init
      spec.branch = e.branch or e.version
      spec.tag = e.tag
      spec.pin = e.pin
    end
    if spec[1] or spec.url or spec.name then
      zoop.add(spec)
      table.insert(added, spec)
    end
  end
  return added
end

return M

