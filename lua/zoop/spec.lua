local util = require('zoop.util')

local M = {}

local function looks_like_repo(s)
  return type(s) == 'string' and s:find('/') ~= nil
end

local function normalize_one(item, cfg)
  local spec = {}
  if type(item) == 'string' then
    spec.repo = item
  elseif type(item) == 'table' then
    -- { 'owner/repo', lazy = true, build = 'make', branch = 'main', tag = 'v1', pin = 'sha' }
    if type(item[1]) == 'string' then
      spec.repo = item[1]
    elseif item.repo then
      spec.repo = item.repo
    elseif item.url then
      spec.url = item.url
      spec.repo = util.basename(item.url):gsub('%.git$', '')
    end
    for k, v in pairs(item) do
      if type(k) == 'string' then spec[k] = v end
    end
  else
    error('Invalid spec: ' .. vim.inspect(item))
  end

  -- repo like 'owner/name' => GitHub URL
  if not spec.url and spec.repo and spec.repo:find('/') then
    spec.url = string.format('https://github.com/%s.git', spec.repo)
  end

  spec.name = spec.name or (spec.repo and spec.repo:match('[^/]+$')) or (spec.url and util.basename(spec.url):gsub('%.git$', ''))
  spec.lazy = not not spec.lazy
  spec.build = spec.build
  spec.build_env = spec.build_env
  spec.submodules = spec.submodules
  -- lifecycle/config and dependency fields
  spec.init = spec.init
  spec.config = spec.config
  spec.main = spec.main
  spec.opts = spec.opts
  -- normalize dependencies to names
  if type(spec.dependencies) == 'table' then
    local deps = {}
    for _, d in ipairs(spec.dependencies) do
      if type(d) == 'string' then
        table.insert(deps, (d:find('/') and d:match('[^/]+$')) or d)
      elseif type(d) == 'table' and type(d[1]) == 'string' then
        local s = d[1]
        table.insert(deps, (s:find('/') and s:match('[^/]+$')) or s)
      end
    end
    spec.dependencies = deps
  end
  if type(spec.modules) == 'string' then spec.modules = { spec.modules } end
  spec.pin = spec.pin
  spec.branch = spec.branch
  spec.tag = spec.tag
  spec.dir = spec.dir -- if user overrides destination

  -- Destination directory layout
  local base = cfg.root
  local bucket = spec.lazy and 'opt' or 'start'
  local dest = spec.dir or util.joinpath(base, bucket, assert(spec.name, 'missing name'))
  spec.dest = dest
  spec.bucket = bucket

  -- Lazy triggers (optional)
  -- cmd, keys, ft, event

  spec._normalized = true
  return spec
end

---@param specs table
---@param cfg table
---@return table normalized
function M.normalize(specs, cfg)
  local out = {}
  for _, item in ipairs(specs or {}) do
    table.insert(out, normalize_one(item, cfg))
  end
  return out
end

-- Create a spec from an "add-like" signature similar to vim.pack.add
-- name_or_spec: string|table
-- opts: table|nil (only used if first arg is string)
function M.from_add(name_or_spec, opts, cfg)
  local spec
  if type(name_or_spec) == 'table' then
    spec = normalize_one(name_or_spec, cfg)
  elseif type(name_or_spec) == 'string' then
    local name = name_or_spec
    local t = {}
    opts = opts or {}
    if looks_like_repo(name) then
      -- e.g. 'owner/repo' => prefer GitHub URL inference; let name be repo tail
      t[1] = name
      -- allow opts to enrich (lazy, build, branch, tag, pin, url override, dir)
      for k,v in pairs(opts) do t[k] = v end
    else
      -- e.g. 'plenary.nvim' with explicit url in opts (vim.pack.add style)
      t.name = name
      for k,v in pairs(opts) do t[k] = v end
      if not t.url and t.repo then
        t.url = string.format('https://github.com/%s.git', t.repo)
      end
    end
    spec = normalize_one(t, cfg)
  else
    error('Invalid add() arguments')
  end
  return spec
end

return M
