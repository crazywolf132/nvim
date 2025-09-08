local cfgmod = require('zoop.config')
local manager = require('zoop.manager')
local util = require('zoop.util')
local specmod = require('zoop.spec')
local registry = require('zoop.registry')
local pack = require('zoop.pack')

local M = {}

local _cfg = cfgmod.resolve({})

function M.setup(opts)
  _cfg = cfgmod.resolve(opts or {})
  util.ensure_dir(_cfg.root)
  util.ensure_dir((_cfg.root) .. '/start')
  util.ensure_dir((_cfg.root) .. '/opt')
  if vim.fn.executable('zoop') ~= 1 then
    util.notify('zoop CLI not found. Please build the Rust CLI and add it to PATH.', vim.log.levels.ERROR)
  end
  -- Legacy: allow setup({ specs = { ... } })
  if _cfg.specs and #_cfg.specs > 0 then
    for _, item in ipairs(_cfg.specs) do
      -- Treat like successive add() calls
      local spec = specmod.from_add(item, nil, _cfg)
      registry.add(spec)
      -- Defer actual install to :ZoopInstall or :ZoopSync
      -- Lazy hooks are registered at install time to avoid stubs for missing dirs.
    end
  end
end

-- zoop.add mirrors vim.pack.add(name, opts), with extra keys: lazy, build, cmd, keys, ft, event
function M.add(name_or_spec, opts)
  local ok, spec = pcall(specmod.from_add, name_or_spec, opts, _cfg)
  if not ok then
    util.notify('zoop.add: invalid spec: ' .. tostring(spec), vim.log.levels.ERROR)
    return
  end
  -- Detect duplicates before mutating registry
  local prev = registry.get(spec.name)
  registry.add(spec)
  -- Detect duplicate names pointing to different URLs
  if prev and prev.url and spec.url and prev.url ~= spec.url then
    util.notify(string.format('Duplicate plugin name %s with different URLs:\n  old: %s\n  new: %s', spec.name, prev.url, spec.url), vim.log.levels.WARN)
  end
  -- Module-based lazy require hooks
  if type(spec.modules) == 'table' then
    for _, m in ipairs(spec.modules) do
      if type(m) == 'string' and package.preload[m] == nil then
        package.preload[m] = function()
          package.preload[m] = nil
          local s = registry.get(spec.name) or spec
          -- init before load
          if type(s.init) == 'function' and not s._init_ran then s._init_ran = true; pcall(s.init) end
          -- ensure deps + plugin are loaded and configured
          local manager_mod = require('zoop.manager')
          if manager_mod and type(manager_mod.ensure_loaded) == 'function' then
            manager_mod.ensure_loaded(s)
          else
            require('zoop.pack').packadd(s.name)
          end
          return require(m)
        end
      end
    end
  end
  -- If plugin already exists and not lazy, make it available now
  if not spec.lazy and require('zoop.util').exists(spec.dest) then
    if type(spec.init) == 'function' and not spec._init_ran then spec._init_ran = true; pcall(spec.init) end
    require('zoop.pack').packadd(spec.name)
    if type(spec.main) == 'string' then
      local okm, mod = pcall(require, spec.main)
      if okm and type(mod) == 'table' and type(mod.setup) == 'function' and not spec._config_ran then spec._config_ran = true; pcall(mod.setup, spec.opts) end
    end
    if type(spec.config) == 'function' and not spec._config_ran then spec._config_ran = true; pcall(spec.config) end
    if type(spec.config) == 'string' and not spec._config_ran then spec._config_ran = true; pcall(require, spec.config) end
  else
    -- Register lazy hooks right away for smooth DX
    local manager_mod = require('zoop.manager')
    local add_to_runtime = function(s)
      require('zoop.pack').packadd(s.name)
    end
    -- Reuse manager’s lazy registration logic indirectly by calling internal helper
    -- Minimal re-implementation here to avoid circular dependency issues
    local name = spec.name
    if spec.cmd then
      local cmds = type(spec.cmd) == 'table' and spec.cmd or { spec.cmd }
      for _, c in ipairs(cmds) do
        vim.api.nvim_create_user_command(c, function()
          add_to_runtime(spec)
          vim.cmd(c)
        end, { nargs = '*', bang = true, complete = 'command' })
      end
    end
    if spec.event then
      local events = type(spec.event) == 'table' and spec.event or { spec.event }
      local aug = vim.api.nvim_create_augroup('ZoopLazyEvent_' .. name, { clear = true })
      vim.api.nvim_create_autocmd(events, { group = aug, once = true, callback = function() add_to_runtime(spec) end })
    end
    if spec.ft then
      local fts = type(spec.ft) == 'table' and spec.ft or { spec.ft }
      local aug = vim.api.nvim_create_augroup('ZoopLazyFt_' .. name, { clear = true })
      vim.api.nvim_create_autocmd('FileType', { group = aug, pattern = fts, once = true, callback = function() add_to_runtime(spec) end })
    end
    if spec.keys then
      local keys = type(spec.keys) == 'table' and spec.keys or { spec.keys }
      for _, k in ipairs(keys) do
        local lhs = type(k) == 'table' and k[1] or k
        local mode = (type(k) == 'table' and k.mode) or 'n'
        vim.keymap.set(mode, lhs, function()
          pcall(vim.keymap.del, mode, lhs)
          add_to_runtime(spec)
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(lhs, true, false, true), 'm', true)
        end, { desc = 'zoop lazy: ' .. name })
      end
    end
    spec._lazy_registered = true
  end
end

function M.install()
  manager.install_all(_cfg, { build_on_install = _cfg.build_on_install ~= false })
end

function M.update()
  manager.update_all(_cfg)
end

function M.build()
  manager.build_all(_cfg)
end

function M.status()
  manager.status(_cfg)
end

function M.clean()
  manager.clean(_cfg)
end

function M.clean_dry_run()
  local cfg = vim.tbl_deep_extend('force', {}, _cfg)
  cfg._dry_clean = true
  manager.clean(cfg)
end

function M.sync()
  local totals = {}
  manager.install_all(_cfg, {
    build_on_install = _cfg.build_on_install ~= false,
    on_complete = function(s1)
      totals.install = s1
      manager.update_all(_cfg, {
        on_complete = function(s2)
          totals.update = s2
          manager.build_all(_cfg, {
            on_complete = function(s3)
              totals.build = s3
              local lines = {
                'Zoop Sync Summary:',
                string.format('- install: %d ok, %d skipped, %d failed, %d built, %d build_failed', s1.installed or 0, s1.skipped or 0, s1.failed or 0, s1.built or 0, s1.build_failed or 0),
                string.format('- update: %d ok, %d skipped, %d failed', s2.updated or 0, s2.skipped or 0, s2.failed or 0),
                string.format('- build:  %d ok, %d skipped, %d failed', s3.built or 0, s3.skipped or 0, s3.failed or 0),
              }
              require('zoop.util').notify(table.concat(lines, '\n'))
            end,
          })
        end,
      })
    end,
  })
end

function M.sync_lock()
  local totals = {}
  local opts = { apply_lock = true }
  manager.install_all(_cfg, {
    apply_lock = true,
    on_complete = function(s1)
      totals.install = s1
      manager.update_all(_cfg, {
        apply_lock = true,
        on_complete = function(s2)
          totals.update = s2
          manager.build_all(_cfg, {
            apply_lock = true,
            on_complete = function(s3)
              totals.build = s3
              local lines = {
                'Zoop Sync (Lock) Summary:',
                string.format('- install: %d ok, %d skipped, %d failed, %d built, %d build_failed', s1.installed or 0, s1.skipped or 0, s1.failed or 0, s1.built or 0, s1.build_failed or 0),
                string.format('- update: %d ok, %d skipped, %d failed', s2.updated or 0, s2.skipped or 0, s2.failed or 0),
                string.format('- build:  %d ok, %d skipped, %d failed', s3.built or 0, s3.skipped or 0, s3.failed or 0),
              }
              require('zoop.util').notify(table.concat(lines, '\n'))
            end,
          })
        end,
      })
    end,
  })
end

function M.lock()
  manager.lock(_cfg)
end

function M.restore()
  manager.restore(_cfg)
end

function M.doctor()
  local lines = { 'Zoop Doctor:' }
  local pack_ok = require('zoop.pack').has_pack()
  local git_ok = require('zoop.util').is_executable('git')
  local cli_ok = require('zoop.util').is_executable('zoop')
  table.insert(lines, string.format('- vim.pack: %s', pack_ok and 'ok' or 'missing'))
  table.insert(lines, string.format('- git:      %s', git_ok and 'ok' or 'missing'))
  table.insert(lines, string.format('- cli:      %s', cli_ok and 'ok (required)' or 'missing (required)'))
  table.insert(lines, string.format('- make:     %s', require('zoop.util').is_executable('make') and 'ok' or 'missing'))
  table.insert(lines, string.format('- cmake:    %s', require('zoop.util').is_executable('cmake') and 'ok' or 'missing'))
  table.insert(lines, string.format('- node:     %s', require('zoop.util').is_executable('node') and 'ok' or 'missing'))
  table.insert(lines, string.format('- cargo:    %s', require('zoop.util').is_executable('cargo') and 'ok' or 'missing'))
  table.insert(lines, string.format('- root:     %s', _cfg.root))
  table.insert(lines, string.format('- lockfile: %s%s', _cfg.lockfile, (vim.loop.fs_stat(_cfg.lockfile) and ' (exists)' or ' (absent)')))
  table.insert(lines, string.format('- cache:    %s (%s)', _cfg.cache_dir, (_cfg.cache_sources and 'enabled' or 'disabled')))
  require('zoop.util').notify(table.concat(lines, '\n'))
end

function M.remove(name)
  manager.remove(_cfg, name)
end

function M.plan()
  manager.plan(_cfg)
end

return M
