local M = {}

local has_vimfs = vim.fs and type(vim.fs.joinpath) == 'function'

function M.joinpath(...)
  if has_vimfs then
    return vim.fs.joinpath(...)
  end
  local parts = {}
  for _, p in ipairs(vim.tbl_flatten({ ... })) do
    p = tostring(p)
    if p ~= '' then table.insert(parts, p) end
  end
  return table.concat(parts, '/'):gsub('//+', '/')
end

function M.notify(msg, level)
  local lvl = level or vim.log.levels.INFO
  local line = string.format('[%s] %s', ({
    [vim.log.levels.TRACE or -1] = 'TRACE',
    [vim.log.levels.DEBUG or 0] = 'DEBUG',
    [vim.log.levels.INFO] = 'INFO',
    [vim.log.levels.WARN] = 'WARN',
    [vim.log.levels.ERROR] = 'ERROR',
  })[lvl] or tostring(lvl), tostring(msg))
  vim.notify('[zoop] ' .. tostring(msg), lvl)
  -- Also log to file for diagnostics
  local fpath = M.log_file()
  if fpath then
    pcall(function()
      local f = io.open(fpath, 'a')
      if f then
        f:write(os.date('%Y-%m-%d %H:%M:%S '), line, '\n')
        f:close()
      end
    end)
  end
end

function M.is_executable(bin)
  return vim.fn.executable(bin) == 1
end

-- best-effort async wrapper around vim.system with fallback
-- cmd: string[]
-- opts: { cwd?: string, env?: table, text?: string|nil }
-- cb: fun(code: integer, signal: integer, stdout: string, stderr: string)
function M.system(cmd, opts, cb)
  opts = opts or {}
  -- If streaming callbacks are requested, prefer jobstart for live stderr/stdout
  if opts.on_stderr or opts.on_stdout then
    local out_acc, err_acc = {}, {}
    local jid = vim.fn.jobstart(cmd, {
      cwd = opts.cwd,
      env = opts.env,
      stdout_buffered = false,
      stderr_buffered = false,
      on_stdout = function(_, data, _)
        if not data then return end
        for _, line in ipairs(data) do
          if line and line ~= '' then
            table.insert(out_acc, line)
            if opts.on_stdout then opts.on_stdout(line) end
          end
        end
      end,
      on_stderr = function(_, data, _)
        if not data then return end
        for _, line in ipairs(data) do
          if line and line ~= '' then
            table.insert(err_acc, line)
            if opts.on_stderr then opts.on_stderr(line) end
          end
        end
      end,
      on_exit = function(_, code, _)
        cb(code or 0, 0, table.concat(out_acc, '\n'), table.concat(err_acc, '\n'))
      end,
    })
    if opts.text and jid > 0 then
      vim.fn.chansend(jid, opts.text)
      vim.fn.chanclose(jid, 'stdin')
    end
    return jid
  end
  -- Otherwise, use vim.system when available for simplicity
  if vim.system then
    local proc = vim.system(cmd, { cwd = opts.cwd, env = opts.env, text = true, stdin = opts.text }, function(res)
      cb(res.code or 0, 0, res.stdout or '', res.stderr or '')
    end)
    return proc
  end
  -- Fallback: synchronous systemlist
  local saved_cwd = vim.loop.cwd()
  if opts.cwd and opts.cwd ~= '' then pcall(vim.fn.chdir, opts.cwd) end
  local out = ''
  if opts.text then
    local tmp = os.tmpname()
    local f = io.open(tmp, 'w')
    if f then f:write(opts.text); f:close() end
    out = table.concat(vim.fn.systemlist(table.concat(cmd, ' ') .. ' < ' .. tmp), '\n')
    os.remove(tmp)
  else
    out = table.concat(vim.fn.systemlist(table.concat(cmd, ' ')), '\n')
  end
  local code = vim.v.shell_error or 0
  if saved_cwd then pcall(vim.fn.chdir, saved_cwd) end
  cb(code, 0, out, '')
end

function M.ensure_dir(path)
  if vim.fn.isdirectory(path) ~= 1 then
    vim.fn.mkdir(path, 'p')
  end
end

function M.dirname(path)
  if vim.fs and type(vim.fs.dirname) == 'function' then
    return vim.fs.dirname(path)
  end
  return (path:gsub('/*$', ''):match('^(.*)/[^/]+$')) or '.'
end

-- is_windows removed; not needed in current design

local _log_file
function M.log_file()
  if _log_file == nil then
    local dir = vim.fn.stdpath('cache') .. '/zoop'
    M.ensure_dir(dir)
    _log_file = dir .. '/zoop.log'
  end
  return _log_file
end

function M.set_log_file(path)
  _log_file = path
end

-- write_file removed (stream JSON via stdin instead)

function M.exists(path)
  return vim.loop.fs_stat(path) ~= nil
end

function M.basename(path)
  return (path:gsub('/*$', ''):match('.*/([^/]+)$')) or path
end

function M.with_concurrency(limit)
  local count = 0
  local queue = {}
  local function run_next()
    if count >= limit then return end
    local item = table.remove(queue, 1)
    if not item then return end
    count = count + 1
    item(function()
      count = count - 1
      run_next()
    end)
  end
  return function(task)
    table.insert(queue, task)
    run_next()
  end
end

return M
