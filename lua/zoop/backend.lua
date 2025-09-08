local util = require('zoop.util')

local M = {}

local function cli_bin()
  -- Require a system-installed CLI named 'zoop'
  if util.is_executable('zoop') then return 'zoop' end
  return nil
end

local function spawn(cmd, opts, cb)
  util.system(cmd, opts, function(code, _, out, err)
    cb(code == 0, out, err)
  end)
end

local function safe_name_from_url(url)
  return (url:gsub('^https?://', ''):gsub('[^%w%.%-_]+', '_'))
end

local function ensure_mirror(url, mirror_dir, cb)
  local bin = cli_bin()
  if not bin then return cb(false) end
  spawn({ bin, 'mirror-ensure', '--url', url, '--path', mirror_dir }, {}, function(ok, _out, _err)
    cb(ok)
  end)
end


function M.install(spec, cfg_or_cb, maybe_cb)
  local cb = maybe_cb or cfg_or_cb
  local cfg = (maybe_cb and cfg_or_cb) or nil
  local bin = cli_bin()
  if not bin then
    return cb(false, 'zoop CLI not found in PATH; build with cargo and add to PATH')
  end
  local args = { bin, 'install', '--url', spec.url, '--dest', spec.dest }
  if spec.branch then table.insert(args, '--branch'); table.insert(args, spec.branch) end
  if spec.tag then table.insert(args, '--tag'); table.insert(args, spec.tag) end
  if spec.pin then table.insert(args, '--pin'); table.insert(args, spec.pin) end
  if spec.submodules then table.insert(args, '--submodules') end
  util.ensure_dir(util.dirname(spec.dest))
  local function run_spawn()
    return spawn(args, {}, function(ok, out, err)
      if not ok then cb(false, err ~= '' and err or out) else cb(true) end
    end)
  end
  if cfg and cfg.cache_sources then
    local mirror = util.joinpath(cfg.cache_dir, safe_name_from_url(spec.url))
    ensure_mirror(spec.url, mirror, function(ok)
      if ok then table.insert(args, '--reference'); table.insert(args, mirror) end
      run_spawn()
    end)
  else
    run_spawn()
  end
end


function M.update(spec, cfg_or_cb, maybe_cb)
  local cb = maybe_cb or cfg_or_cb
  local cfg = (maybe_cb and cfg_or_cb) or nil
  local bin = cli_bin()
  if not bin then
    return cb(false, 'zoop CLI not found in PATH; build with cargo and add to PATH')
  end
  local args = { bin, 'update', '--dest', spec.dest }
  if spec.branch then table.insert(args, '--branch'); table.insert(args, spec.branch) end
  if spec.tag then table.insert(args, '--tag'); table.insert(args, spec.tag) end
  if spec.submodules then table.insert(args, '--submodules') end
  local function run_spawn()
    return spawn(args, {}, function(ok, out, err)
      if not ok then cb(false, err ~= '' and err or out) else cb(true) end
    end)
  end
  if cfg and cfg.cache_sources then
    M.remote_url(spec.dest, function(ok, url)
      if ok and url then
        local mirror = util.joinpath(cfg.cache_dir, safe_name_from_url(url))
        ensure_mirror(url, mirror, function(okm)
          if okm then table.insert(args, '--reference'); table.insert(args, mirror) end
          run_spawn()
        end)
      else
        run_spawn()
      end
    end)
  else
    run_spawn()
  end
end

function M.build(spec, cfg_or_cb, maybe_cb)
  local cb = maybe_cb or cfg_or_cb
  if not spec.build or spec.build == '' then return cb(true) end
  local bin = cli_bin()
  if not bin then
    return cb(false, 'zoop CLI not found in PATH; build with cargo and add to PATH')
  end
  local args = { bin, 'build', '--dest', spec.dest, '--cmd', spec.build }
  if spec.build_env and type(spec.build_env) == 'table' then
    for k, v in pairs(spec.build_env) do
      table.insert(args, '--env'); table.insert(args, string.format('%s=%s', k, v))
    end
  end
  return spawn(args, {}, function(ok, out, err)
    if not ok then cb(false, err ~= '' and err or out) else cb(true) end
  end)
end

-- Utilities for status/lock/restore
function M.current_rev(dest, cb)
  M.status(dest, function(ok, info, err)
    if not ok then return cb(false, nil, err) end
    cb(true, info.rev)
  end)
end

function M.remote_url(dest, cb)
  M.status(dest, function(ok, info, err)
    if not ok then return cb(false, nil, err) end
    cb(true, info.remote_url)
  end)
end

function M.checkout(dest, commit, cb)
  if not commit or commit == '' then return cb(true) end
  local bin = cli_bin()
  if not bin then return cb(false, 'zoop CLI not found in PATH; build with cargo and add to PATH') end
  spawn({ bin, 'checkout', '--dest', dest, '--commit', commit }, {}, function(ok, out, err)
    if not ok then return cb(false, err ~= '' and err or out) end
    cb(true)
  end)
end

function M.current_branch(dest, cb)
  M.status(dest, function(ok, info, err)
    if not ok then return cb(false, nil, err) end
    cb(true, info.branch)
  end)
end

function M.ahead_behind(dest, branch, cb)
  M.status(dest, function(ok, info, err)
    if not ok then return cb(false, nil, err) end
    cb(true, { ahead = info.ahead or 0, behind = info.behind or 0 })
  end)
end

function M.status(dest, cb)
  local bin = cli_bin()
  if not bin then return cb(false, nil, 'zoop CLI not found in PATH') end
  spawn({ bin, 'status', '--dest', dest, '--json' }, {}, function(ok, out, err)
    if not ok then return cb(false, nil, err ~= '' and err or out) end
    local okj, info = pcall(vim.json.decode, out)
    if not okj then return cb(false, nil, 'invalid JSON from status') end
    cb(true, info)
  end)
end

-- Batch status: dests: string[] -> cb(true, array-of-infos)
function M.status_many(dests, cb)
  local bin = cli_bin()
  if not bin then return cb(false, nil, 'zoop CLI not found in PATH') end
  local cmd = { bin, 'status', '--json' }
  for _, d in ipairs(dests) do table.insert(cmd, '--dest'); table.insert(cmd, d) end
  spawn(cmd, {}, function(ok, out, err)
    if not ok then return cb(false, nil, err ~= '' and err or out) end
    local okj, info = pcall(vim.json.decode, out)
    if not okj then return cb(false, nil, 'invalid JSON from status') end
    cb(true, info)
  end)
end

-- lock: specs -> JSON mapping name -> lock entry
function M.lock(specs, cb)
  local bin = cli_bin()
  if not bin then return cb(false, nil, 'zoop CLI not found in PATH') end
  local payload = vim.json.encode(specs)
  spawn({ bin, 'lock', '--in', '-' }, {
    text = payload,
    on_stderr = function(line)
      if line and line:match('^%[zoop%]') then require('zoop.util').notify(line) end
    end,
  }, function(ok, out, err)
    if not ok then return cb(false, nil, err ~= '' and err or out) end
    local okj, info = pcall(vim.json.decode, out)
    if not okj then return cb(false, nil, 'invalid JSON from lock') end
    cb(true, info)
  end)
end

function M.restore(items, cb)
  local bin = cli_bin()
  if not bin then return cb(false, nil, 'zoop CLI not found in PATH') end
  local payload = vim.json.encode(items)
  spawn({ bin, 'restore', '--in', '-' }, {
    text = payload,
    on_stderr = function(line)
      if line and line:match('^%[zoop%]') then require('zoop.util').notify(line) end
    end,
  }, function(ok, out, err)
    if not ok then return cb(false, nil, err ~= '' and err or out) end
    local okj, info = pcall(vim.json.decode, out)
    if not okj then return cb(false, nil, 'invalid JSON from restore') end
    cb(true, info)
  end)
end

function M.install_many(items, cfg, cb)
  local bin = cli_bin()
  if not bin then return cb(false, nil, 'zoop CLI not found in PATH') end
  local cmd = { bin, 'install-batch', '--in', '-' }
  local opts = {
    text = vim.json.encode(items),
    on_stderr = function(line)
      if line and line:match('^%[zoop%]') then require('zoop.util').notify(line) end
    end,
  }
  if cfg and cfg.concurrency then opts.env = { ZOOP_JOBS = tostring(cfg.concurrency) } end
  spawn(cmd, opts, function(ok, out, err)
    if not ok then return cb(false, nil, err ~= '' and err or out) end
    local okj, res = pcall(vim.json.decode, out)
    if not okj then return cb(false, nil, 'invalid JSON from install-batch') end
    cb(true, res)
  end)
end

function M.update_many(items, cfg, cb)
  local bin = cli_bin()
  if not bin then return cb(false, nil, 'zoop CLI not found in PATH') end
  local cmd = { bin, 'update-batch', '--in', '-' }
  local opts = {
    text = vim.json.encode(items),
    on_stderr = function(line)
      if line and line:match('^%[zoop%]') then require('zoop.util').notify(line) end
    end,
  }
  if cfg and cfg.concurrency then opts.env = { ZOOP_JOBS = tostring(cfg.concurrency) } end
  spawn(cmd, opts, function(ok, out, err)
    if not ok then return cb(false, nil, err ~= '' and err or out) end
    local okj, res = pcall(vim.json.decode, out)
    if not okj then return cb(false, nil, 'invalid JSON from update-batch') end
    cb(true, res)
  end)
end

function M.build_many(items, cfg, cb)
  local bin = cli_bin()
  if not bin then return cb(false, nil, 'zoop CLI not found in PATH') end
  local cmd = { bin, 'build-batch', '--in', '-' }
  local opts = {
    text = vim.json.encode(items),
    on_stderr = function(line)
      if line and line:match('^%[zoop%]') then require('zoop.util').notify(line) end
    end,
  }
  if cfg and cfg.concurrency then opts.env = { ZOOP_JOBS = tostring(cfg.concurrency) } end
  spawn(cmd, opts, function(ok, out, err)
    if not ok then return cb(false, nil, err ~= '' and err or out) end
    local okj, res = pcall(vim.json.decode, out)
    if not okj then return cb(false, nil, 'invalid JSON from build-batch') end
    cb(true, res)
  end)
end

function M.clean(root, keep_list, dry_run, cb)
  local bin = cli_bin()
  if not bin then return cb(false, nil, 'zoop CLI not found in PATH') end
  local cmd = { bin, 'clean', '--root', root, '--keep', '-' }
  if dry_run then table.insert(cmd, '--dry-run') end
  spawn(cmd, { text = vim.json.encode(keep_list) }, function(ok, out, err)
    if not ok then return cb(false, nil, err ~= '' and err or out) end
    cb(true, out)
  end)
end

return M
