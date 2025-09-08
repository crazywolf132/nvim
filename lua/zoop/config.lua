local M = {}

-- Default configuration. Users can override via require('zoop').setup({ ... }).
M.defaults = {
  -- Root of the pack directory used by zoop. If nil, defaults to stdpath('data')/site/pack/zoop
  root = nil,
  -- Path to lockfile (reproducible installs). If nil, defaults to stdpath('config')/zoop.lock.json
  lockfile = nil,
  -- Maximum concurrent spawns for operations (best-effort; simple limiter).
  concurrency = 4,
  -- Enforce lockfile pins during install/update (reproducible mode)
  enforce_lock = false,
  -- Run build steps automatically after installs
  build_on_install = true,
  -- Plugin specs: list of strings ('owner/repo') or tables with options.
  specs = {},
  -- Logging level: vim.log.levels.<LEVEL>
  log_level = vim.log.levels.INFO,
  -- Use local git mirror cache to speed up clones
  cache_sources = true,
  -- Where mirrors are stored; default to stdpath('cache')/zoop/sources
  cache_dir = nil,
}

---@param user table|nil
---@return table cfg
function M.resolve(user)
  local cfg = vim.tbl_deep_extend('force', {}, M.defaults, user or {})
  if not cfg.root or cfg.root == '' then
    local site = vim.fn.stdpath('data') .. '/site'
    cfg.root = site .. '/pack/zoop'
  end
  if not cfg.lockfile or cfg.lockfile == '' then
    cfg.lockfile = vim.fn.stdpath('config') .. '/zoop.lock.json'
  end
  if not cfg.cache_dir or cfg.cache_dir == '' then
    cfg.cache_dir = vim.fn.stdpath('cache') .. '/zoop/sources'
  end
  -- Environment overrides
  local env_conc = tonumber(vim.env.ZOOP_CONCURRENCY or '')
  if env_conc and env_conc > 0 then cfg.concurrency = env_conc end
  return cfg
end

return M
