local M = {}

local function get_specs()
  local ok, reg = pcall(require, 'zoop.registry')
  if not ok then return {} end
  return reg.all()
end

local function to_entries(specs, infos, lock)
  local entries = {}
  for i, s in ipairs(specs) do
    local info = infos and infos[i] or nil
    local status = 'missing'
    local suffix = ''
    if info and info.rev then
      status = 'installed'
      suffix = string.sub(info.rev, 1, 7)
      local lockrev = (lock and lock[s.name]) and (lock[s.name].commit or lock[s.name].pin) or nil
      if lockrev and lockrev ~= info.rev then
        suffix = suffix .. ' ≠ ' .. string.sub(lockrev, 1, 7)
      end
      if info.ahead or info.behind then
        suffix = suffix .. string.format(' [↑%d ↓%d]', info.ahead or 0, info.behind or 0)
      end
    end
    table.insert(entries, {
      name = s.name,
      spec = s,
      status = status,
      display = string.format('%-24s %s %s', s.name, status, suffix),
    })
  end
  return entries
end

function M.status_picker()
  local ok, telescope = pcall(require, 'telescope')
  if not ok then
    vim.notify('Telescope not available', vim.log.levels.ERROR)
    return
  end
  local pickers = require('telescope.pickers')
  local finders = require('telescope.finders')
  local conf = require('telescope.config').values
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')

  local specs = get_specs()
  if #specs == 0 then
    vim.notify('No zoop specs registered', vim.log.levels.WARN)
    return
  end

  -- collect status in batch
  local dests = {}
  local lock = require('zoop.manager')._read_lock(require('zoop.config').resolve({}))
  for _, s in ipairs(specs) do table.insert(dests, s.dest) end
  require('zoop.backend').status_many(dests, function(okb, infos)
    if not okb then infos = {} end
    local entries = to_entries(specs, infos, lock)
    pickers.new({}, {
      prompt_title = 'Zoop Status',
      finder = finders.new_table({
        results = entries,
        entry_maker = function(e)
          return {
            value = e,
            display = e.display,
            ordinal = e.display,
          }
        end,
      }),
      sorter = conf.generic_sorter({}),
      attach_mappings = function(prompt_bufnr, map)
        local function get_sel()
          local sel = action_state.get_selected_entry()
          return sel and sel.value or nil
        end
        local function do_open()
          local e = get_sel(); if not e then return end
          vim.cmd('tabnew ' .. vim.fn.fnameescape(e.spec.dest))
        end
        local function do_update()
          local e = get_sel(); if not e then return end
          require('zoop.backend').update(e.spec, function(ok, err)
            if not ok then vim.notify('Update failed: ' .. (err or 'unknown'), vim.log.levels.ERROR) else vim.notify('Updated ' .. e.name) end
          end)
        end
        local function do_build()
          local e = get_sel(); if not e then return end
          require('zoop.backend').build(e.spec, function(ok, err)
            if not ok then vim.notify('Build failed: ' .. (err or 'unknown'), vim.log.levels.ERROR) else vim.notify('Built ' .. e.name) end
          end)
        end
        local function do_checkout_pin()
          local e = get_sel(); if not e then return end
          local l = lock and lock[e.name]
          if not l or not (l.pin or l.commit) then
            vim.notify('No pin in lockfile for ' .. e.name, vim.log.levels.WARN)
            return
          end
          require('zoop.backend').checkout(e.spec.dest, l.pin or l.commit, function(ok, err)
            if not ok then vim.notify('Checkout failed: ' .. (err or 'unknown'), vim.log.levels.ERROR) else vim.notify('Checked out pin for ' .. e.name) end
          end)
        end

        actions.select_default:replace(function() actions.close(prompt_bufnr); do_open() end)
        map('i', '<C-o>', function() do_open() end)
        map('n', '<C-o>', function() do_open() end)
        map('i', '<C-u>', function() do_update() end)
        map('n', '<C-u>', function() do_update() end)
        map('i', '<C-b>', function() do_build() end)
        map('n', '<C-b>', function() do_build() end)
        map('i', '<C-p>', function() do_checkout_pin() end)
        map('n', '<C-p>', function() do_checkout_pin() end)
        return true
      end,
    }):find()
  end)
end

function M.snapshot_picker()
  local ok, telescope = pcall(require, 'telescope')
  if not ok then
    vim.notify('Telescope not available', vim.log.levels.ERROR)
    return
  end
  local pickers = require('telescope.pickers')
  local finders = require('telescope.finders')
  local conf = require('telescope.config').values
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')

  local list = require('zoop.manager').snapshot_list()
  if #list == 0 then
    vim.notify('No snapshots found', vim.log.levels.WARN)
    return
  end
  pickers.new({}, {
    prompt_title = 'Zoop Snapshots',
    finder = finders.new_table({
      results = list,
      entry_maker = function(e)
        return { value = e, display = e, ordinal = e }
      end,
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      local function restore()
        local sel = action_state.get_selected_entry()
        if not sel then return end
        actions.close(prompt_bufnr)
        require('zoop.manager').snapshot_restore(require('zoop.config').resolve({}), sel.value)
      end
      actions.select_default:replace(restore)
      map('i', '<CR>', restore)
      map('n', '<CR>', restore)
      return true
    end,
  }):find()
end

return M
