local util = require('zoop.util')
local pack = require('zoop.pack')
local backend = require('zoop.backend')
local specmod = require('zoop.spec')
local registry = require('zoop.registry')

local M = {}

local function apply_init(spec)
  if spec._init_ran then return end
  spec._init_ran = true
  if type(spec.init) == 'function' then
    pcall(spec.init)
  end
end

local function apply_config(spec)
  if spec._config_ran then return end
  spec._config_ran = true
  -- main module + opts
  if type(spec.main) == 'string' then
    local okm, mod = pcall(require, spec.main)
    if okm and type(mod) == 'table' and type(mod.setup) == 'function' then
      pcall(mod.setup, spec.opts)
    end
  end
  -- explicit config function
  if type(spec.config) == 'function' then
    pcall(spec.config)
  elseif type(spec.config) == 'string' then
    pcall(require, spec.config)
  end
end

local function ensure_loaded_recursive(name, seen)
  seen = seen or {}
  if seen[name] then return end
  seen[name] = true
  local spec = registry.get(name)
  if not spec then
    pack.packadd(name)
    return
  end
  -- load dependencies first
  if type(spec.dependencies) == 'table' then
    for _, dep in ipairs(spec.dependencies) do
      ensure_loaded_recursive(dep, seen)
    end
  end
  apply_init(spec)
  pack.packadd(spec.name)
  apply_config(spec)
end

local function ensure_loaded(spec)
  return ensure_loaded_recursive(spec.name, {})
end

-- expose for module-based require hooks
M.ensure_loaded = ensure_loaded

local function lazy_register(spec)
  if spec._lazy_registered then return end
  local name = spec.name
  -- Command-based lazy loading
  if spec.cmd then
    local cmds = type(spec.cmd) == 'table' and spec.cmd or { spec.cmd }
    for _, c in ipairs(cmds) do
      vim.api.nvim_create_user_command(c, function()
        apply_init(spec)
        ensure_loaded(spec)
        -- Re-execute the command after loading
        vim.cmd(c)
      end, { nargs = '*', bang = true, complete = 'command' })
    end
  end

  -- Event-based lazy loading
  if spec.event then
    local events = type(spec.event) == 'table' and spec.event or { spec.event }
    local aug = vim.api.nvim_create_augroup('ZoopLazyEvent_' .. name, { clear = true })
    vim.api.nvim_create_autocmd(events, {
      group = aug,
      once = true,
      callback = function()
        apply_init(spec)
        ensure_loaded(spec)
      end,
    })
  end

  -- Filetype-based lazy loading
  if spec.ft then
    local fts = type(spec.ft) == 'table' and spec.ft or { spec.ft }
    local aug = vim.api.nvim_create_augroup('ZoopLazyFt_' .. name, { clear = true })
    vim.api.nvim_create_autocmd('FileType', {
      group = aug,
      pattern = fts,
      once = true,
      callback = function()
        apply_init(spec)
        ensure_loaded(spec)
      end,
    })
  end

  -- Keymap-based lazy loading
  if spec.keys then
    local keys = type(spec.keys) == 'table' and spec.keys or { spec.keys }
    for _, k in ipairs(keys) do
      local lhs = type(k) == 'table' and k[1] or k
      local mode = (type(k) == 'table' and k.mode) or 'n'
      vim.keymap.set(mode, lhs, function()
        pcall(vim.keymap.del, mode, lhs)
        apply_init(spec)
        ensure_loaded(spec)
        -- Replay the key after loading
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(lhs, true, false, true), 'm', true)
      end, { desc = 'zoop lazy: ' .. name })
    end
  end
end

local function add_to_runtime(spec)
  if spec.lazy then
    lazy_register(spec)
  else
    -- Non-lazy: ensure available now for current session
    apply_init(spec)
    ensure_loaded(spec)
  end
end

---@param cfg table
---@param opts table|nil
---@return table normalized_specs
function M.normalize(cfg, opts)
  -- Compose from registry first (preferred), fall back to cfg.specs for legacy setup
  local from_reg = registry.all()
  local specs = (#from_reg > 0) and from_reg or specmod.normalize(cfg.specs or {}, cfg)
  -- Apply lock pins when enforced
  local apply_lock = cfg.enforce_lock or (opts and opts.apply_lock)
  if apply_lock then
    local lock = M._read_lock(cfg)
    if lock then
      for _, s in ipairs(specs) do
        local e = lock[s.name]
        if e then
          s.url = e.url or s.url
          s.pin = e.pin or e.commit or s.pin
          s.branch = e.branch or s.branch
          s.tag = e.tag or s.tag
        end
      end
    end
  end
  return specs
end

---@param cfg table
---@param opts table|nil
function M.install_all(cfg, opts)
  opts = opts or {}
  local specs = M.normalize(cfg, opts)
  local summary = { installed = 0, skipped = 0, failed = 0, built = 0, build_failed = 0 }
  local to_install, map = {}, {}
  for _, s in ipairs(specs) do
    map[s.name] = s
    if util.exists(s.dest) then
      summary.skipped = summary.skipped + 1
      add_to_runtime(s)
    else
      table.insert(to_install, {
        name = s.name,
        url = s.url,
        dest = s.dest,
        branch = s.branch,
        tag = s.tag,
        pin = s.pin,
        submodules = s.submodules,
        reference = (cfg.cache_sources and (util.joinpath(cfg.cache_dir, (s.url or ''):gsub('^https?://',''):gsub('[^%w%.%-_]+','_')))) or nil,
      })
    end
  end
  if #to_install == 0 then
    if opts.on_complete then opts.on_complete(summary) end
    return
  end
  backend.install_many(to_install, cfg, function(ok, results, err)
    if not ok then
      util.notify('Batch install failed: ' .. (err or 'unknown'), vim.log.levels.ERROR)
      if opts.on_complete then opts.on_complete(summary) end
      return
    end
    local to_build = {}
    for _, r in ipairs(results or {}) do
      if r.ok then
        summary.installed = summary.installed + 1
        local s = map[r.name]
        if s then
          add_to_runtime(s)
          if s.build and (opts.build_on_install ~= false) then
            table.insert(to_build, { name = s.name, dest = s.dest, cmd = s.build, env = s.build_env })
          end
        end
      else
        summary.failed = summary.failed + 1
        util.notify(string.format('Install failed for %s: %s', r.name, r.error or 'unknown'), vim.log.levels.ERROR)
      end
    end
    if #to_build == 0 then
      if opts.on_complete then opts.on_complete(summary) end
      return
    end
    backend.build_many(to_build, cfg, function(okb, bresults, berr)
      if not okb then
        util.notify('Batch build failed: ' .. (berr or 'unknown'), vim.log.levels.ERROR)
        if opts.on_complete then opts.on_complete(summary) end
        return
      end
      for _, br in ipairs(bresults or {}) do
        if br.ok then summary.built = summary.built + 1 else summary.build_failed = summary.build_failed + 1 end
      end
      if opts.on_complete then opts.on_complete(summary) end
    end)
  end)
end

---@param cfg table
function M.update_all(cfg, opts)
  opts = opts or {}
  local specs = M.normalize(cfg, opts)
  local summary = { updated = 0, failed = 0, skipped = 0 }
  local items = {}
  for _, s in ipairs(specs) do
    if util.exists(s.dest) then
      if s.pin and s.pin ~= '' then
        summary.skipped = summary.skipped + 1
      else
        table.insert(items, {
          name = s.name,
          dest = s.dest,
          branch = s.branch,
          tag = s.tag,
          submodules = s.submodules,
          -- reference left nil; could be derived from remote
        })
      end
    else
      summary.skipped = summary.skipped + 1
    end
  end
  if #items == 0 then
    if opts.on_complete then opts.on_complete(summary) end
    return
  end
  backend.update_many(items, cfg, function(ok, results, err)
    if not ok then
      util.notify('Batch update failed: ' .. (err or 'unknown'), vim.log.levels.ERROR)
      if opts.on_complete then opts.on_complete(summary) end
      return
    end
    for _, r in ipairs(results or {}) do
      if r.ok then summary.updated = summary.updated + 1 else summary.failed = summary.failed + 1 end
    end
    if opts.on_complete then opts.on_complete(summary) end
  end)
end

---@param cfg table
function M.build_all(cfg, opts)
  opts = opts or {}
  local specs = M.normalize(cfg, opts)
  local summary = { built = 0, failed = 0, skipped = 0 }
  local items = {}
  for _, s in ipairs(specs) do
    if util.exists(s.dest) and s.build then
      table.insert(items, { name = s.name, dest = s.dest, cmd = s.build, env = s.build_env })
    else
      summary.skipped = summary.skipped + 1
    end
  end
  if #items == 0 then
    if opts.on_complete then opts.on_complete(summary) end
    return
  end
  backend.build_many(items, cfg, function(ok, results, err)
    if not ok then
      util.notify('Batch build failed: ' .. (err or 'unknown'), vim.log.levels.ERROR)
      if opts.on_complete then opts.on_complete(summary) end
      return
    end
    for _, r in ipairs(results or {}) do
      if r.ok then summary.built = summary.built + 1 else summary.failed = summary.failed + 1 end
    end
    if opts.on_complete then opts.on_complete(summary) end
  end)
end

---@param cfg table
function M.status(cfg)
  local specs = M.normalize(cfg)
  local lines = { 'zoop status:' }
  local lock = M._read_lock(cfg)
  local installed = {}
  local index = {}
  for _, s in ipairs(specs) do
    if util.exists(s.dest) then
      table.insert(installed, s.dest)
      index[s.dest] = s
    else
      table.insert(lines, string.format(' - %-24s missing', s.name))
    end
  end
  if #installed == 0 then
    util.notify(table.concat(lines, '\n'))
    return
  end
  require('zoop.backend').status_many(installed, function(ok, infos)
    if not ok or type(infos) ~= 'table' then
      util.notify('status_many failed', vim.log.levels.ERROR)
      return
    end
    for i, dest in ipairs(installed) do
      local s = index[dest]
      local info = infos[i]
      local suffix = ''
      if info and info.rev then
        suffix = string.format(' @ %s', string.sub(info.rev, 1, 7))
        local lockrev = (lock and lock[s.name]) and (lock[s.name].commit or lock[s.name].pin) or nil
        if lockrev and lockrev ~= info.rev then
          suffix = suffix .. string.format(' (≠ lock %s)', string.sub(lockrev, 1, 7))
        end
        if info.ahead or info.behind then
          suffix = suffix .. string.format(' [↑%d ↓%d]', info.ahead or 0, info.behind or 0)
        end
      end
      table.insert(lines, string.format(' - %-24s installed%s', s.name, suffix))
    end
    util.notify(table.concat(lines, '\n'))
  end)
end

---@param cfg table
function M.clean(cfg)
  local keep = {}
  local list = {}
  for _, s in ipairs(M.normalize(cfg)) do
    keep[s.dest] = true
    table.insert(list, s.dest)
  end
  require('zoop.backend').clean(cfg.root, list, cfg._dry_clean or false, function(ok, out, err)
    if not ok then
      util.notify('Clean failed: ' .. (err or 'unknown'), vim.log.levels.ERROR)
      return
    end
    if cfg._dry_clean then
      util.notify((out or ''))
    else
      local okj, removed = pcall(vim.json.decode, out)
      if okj and type(removed) == 'table' then
        util.notify(string.format('Removed %d directories', #removed))
      else
        util.notify('Cleaned unmanaged directories')
      end
    end
  end)
end

function M.plan(cfg)
  local specs = M.normalize(cfg)
  local lines = { 'Zoop Plan:' }
  for _, s in ipairs(specs) do
    if util.exists(s.dest) then
      table.insert(lines, string.format('- keep %-24s (%s)', s.name, s.bucket))
    else
      table.insert(lines, string.format('- install %-21s from %s', s.name, s.url or (s.repo or '?')))
    end
  end
  -- Show removals
  local keep = {}
  for _, s in ipairs(specs) do keep[s.dest] = true end
  for _, bucket in ipairs({ 'start', 'opt' }) do
    local dir = util.joinpath(cfg.root, bucket)
    local fs = vim.loop.fs_scandir(dir)
    if fs then
      while true do
        local name, t = vim.loop.fs_scandir_next(fs)
        if not name then break end
        if t == 'directory' then
          local path = util.joinpath(dir, name)
          if not keep[path] then
            table.insert(lines, string.format('- remove  %s', path))
          end
        end
      end
    end
  end
  util.notify(table.concat(lines, '\n'))
end

-- Lockfile helpers
function M._read_lock(cfg)
  local path = cfg.lockfile
  local ok, data = pcall(vim.fn.readfile, path)
  if not ok or type(data) ~= 'table' then return nil end
  local content = table.concat(data, '\n')
  local okj, obj = pcall(vim.json.decode, content)
  if not okj then return nil end
  return obj
end

function M.lock(cfg)
  local specs = M.normalize(cfg)
  local input = {}
  for _, s in ipairs(specs) do
    table.insert(input, {
      name = s.name,
      dest = s.dest,
      url = s.url,
      branch = s.branch,
      tag = s.tag,
      pin = s.pin,
    })
  end
  require('zoop.backend').lock(input, function(ok, mapping, err)
    if not ok or type(mapping) ~= 'table' then
      util.notify('Lock failed: ' .. (err or 'unknown'), vim.log.levels.ERROR)
      return
    end
    vim.fn.writefile(vim.split(vim.json.encode(mapping), '\n', { plain = true }), cfg.lockfile)
    util.notify('Wrote lockfile: ' .. cfg.lockfile)
  end)
end

function M.restore(cfg)
  local lock = M._read_lock(cfg)
  if not lock then
    util.notify('No lockfile found at ' .. cfg.lockfile, vim.log.levels.WARN)
    return
  end
  local specs = M.normalize(cfg)
  local items = {}
  for _, s in ipairs(specs) do
    local e = lock[s.name]
    if e then
      table.insert(items, {
        name = s.name,
        dest = s.dest,
        url = e.url or s.url,
        branch = e.branch or s.branch,
        tag = e.tag or s.tag,
        pin = e.pin or e.commit,
        commit = e.commit,
      })
    end
  end
  if #items == 0 then
    util.notify('Nothing to restore (no matching entries)', vim.log.levels.WARN)
    return
  end
  require('zoop.backend').restore(items, function(ok, results, err)
    if not ok then
      util.notify('Restore failed: ' .. (err or 'unknown'), vim.log.levels.ERROR)
      return
    end
    local okc, failc = 0, 0
    for _, r in ipairs(results or {}) do
      if r.ok then okc = okc + 1 else failc = failc + 1 end
    end
    util.notify(string.format('Zoop Restore: %d ok, %d failed', okc, failc))
  end)
end

-- Snapshots
local function snapshots_dir()
  return vim.fn.stdpath('config') .. '/zoop/snapshots'
end

function M.snapshot(cfg, name)
  local lock = M._read_lock(cfg)
  if not lock then
    util.notify('No lockfile to snapshot. Run :ZoopLock first.', vim.log.levels.WARN)
    return
  end
  local dir = snapshots_dir()
  util.ensure_dir(dir)
  local stamp = name or os.date('%Y%m%d-%H%M%S')
  local path = util.joinpath(dir, stamp .. '.json')
  vim.fn.writefile(vim.split(vim.json.encode(lock), '\n', { plain = true }), path)
  util.notify('Snapshot saved: ' .. path)
end

function M.snapshot_list()
  local dir = snapshots_dir()
  local list = {}
  local fs = vim.loop.fs_scandir(dir)
  if fs then
    while true do
      local name, t = vim.loop.fs_scandir_next(fs)
      if not name then break end
      if t == 'file' then table.insert(list, name) end
    end
  end
  table.sort(list)
  return list
end

function M.snapshot_restore(cfg, name)
  local path = util.joinpath(snapshots_dir(), name)
  local okf, lines = pcall(vim.fn.readfile, path)
  if not okf then util.notify('Failed to read snapshot: ' .. path, vim.log.levels.ERROR); return end
  local okj, lock = pcall(vim.json.decode, table.concat(lines, '\n'))
  if not okj then util.notify('Invalid snapshot JSON: ' .. path, vim.log.levels.ERROR); return end
  local specs = M.normalize(cfg)
  local items = {}
  for _, s in ipairs(specs) do
    local e = lock[s.name]
    if e then
      table.insert(items, {
        name = s.name,
        dest = s.dest,
        url = e.url or s.url,
        branch = e.branch or s.branch,
        tag = e.tag or s.tag,
        pin = e.pin or e.commit,
        commit = e.commit,
      })
    end
  end
  if #items == 0 then util.notify('No matching entries in snapshot', vim.log.levels.WARN); return end
  require('zoop.backend').restore(items, function(ok, results, err)
    if not ok then util.notify('Snapshot restore failed: ' .. (err or 'unknown'), vim.log.levels.ERROR); return end
    local okc, failc = 0, 0
    for _, r in ipairs(results or {}) do if r.ok then okc = okc + 1 else failc = failc + 1 end end
    util.notify(string.format('Snapshot Restore: %d ok, %d failed', okc, failc))
  end)
end

function M.remove(cfg, name)
  if not name or name == '' then return util.notify('ZoopRemove: missing name', vim.log.levels.ERROR) end
  local specs = M.normalize(cfg)
  for _, s in ipairs(specs) do
    if s.name == name then
      if s.dest:sub(1, #cfg.root) == cfg.root then
        util.notify('Removing ' .. s.dest)
        vim.fn.delete(s.dest, 'rf')
        return
      else
        util.notify('Refusing to remove outside root: ' .. s.dest, vim.log.levels.ERROR)
        return
      end
    end
  end
  util.notify('Plugin not found in specs: ' .. name, vim.log.levels.WARN)
end

return M
