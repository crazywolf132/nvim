local M = {}

-- Build states
M.states = {
  NOT_FOUND = "not_found",
  FOUND = "found",
  RUNNING = "running",
  PASSED = "passed",
  FAILED = "failed",
}

-- Current state
M.current_state = M.states.NOT_FOUND
M.build_file_path = nil
M.last_run_time = nil
M.job_id = nil

-- Icons and colors for each state
M.icons = {
  [M.states.NOT_FOUND] = "",
  [M.states.FOUND] = "󰆥",
  [M.states.RUNNING] = "󰄱",
  [M.states.PASSED] = "󰄬",
  [M.states.FAILED] = "󰅖",
}

M.colors = {
  [M.states.NOT_FOUND] = "Comment",
  [M.states.FOUND] = "Normal",
  [M.states.RUNNING] = "DiagnosticWarn",
  [M.states.PASSED] = "DiagnosticOk",
  [M.states.FAILED] = "DiagnosticError",
}

-- Find build.sh in project root
function M.find_build_file()
  local cwd = vim.fn.getcwd()
  local build_path = cwd .. "/build.sh"
  
  if vim.fn.filereadable(build_path) == 1 then
    M.build_file_path = build_path
    if M.current_state == M.states.NOT_FOUND then
      M.current_state = M.states.FOUND
    end
    return true
  else
    M.build_file_path = nil
    M.current_state = M.states.NOT_FOUND
    return false
  end
end

-- Execute build.sh
function M.run_build()
  if not M.find_build_file() then
    vim.notify("No build.sh found in project root", vim.log.levels.WARN)
    return
  end
  
  -- Kill existing job if running
  if M.job_id and vim.fn.jobwait({ M.job_id }, 0)[1] == -1 then
    vim.fn.jobstop(M.job_id)
  end
  
  M.current_state = M.states.RUNNING
  M.last_run_time = os.time()
  
  -- Ensure the file is executable
  vim.fn.system("chmod +x " .. M.build_file_path)
  
  local output = {}
  M.job_id = vim.fn.jobstart(M.build_file_path, {
    on_stdout = function(_, data)
      if data then
        vim.list_extend(output, data)
      end
    end,
    on_stderr = function(_, data)
      if data then
        vim.list_extend(output, data)
      end
    end,
    on_exit = function(_, exit_code)
      if exit_code == 0 then
        M.current_state = M.states.PASSED
        vim.notify("Build passed!", vim.log.levels.INFO)
      else
        M.current_state = M.states.FAILED
        vim.notify("Build failed! Exit code: " .. exit_code, vim.log.levels.ERROR)
        if #output > 0 then
          vim.notify(table.concat(output, "\n"), vim.log.levels.ERROR)
        end
      end
      -- Force statusline update
      vim.cmd("redrawstatus")
    end,
  })
end

-- Get current icon and highlight group
function M.get_display()
  local icon = M.icons[M.current_state] or ""
  local color = M.colors[M.current_state] or "Normal"
  return icon, color
end

-- Setup function
function M.setup(opts)
  opts = opts or {}
  
  -- Override icons if provided
  if opts.icons then
    M.icons = vim.tbl_extend("force", M.icons, opts.icons)
  end
  
  -- Override colors if provided
  if opts.colors then
    M.colors = vim.tbl_extend("force", M.colors, opts.colors)
  end
  
  -- Initial check for build file
  M.find_build_file()
  
  -- Set up autocommand to check for build file on directory change
  vim.api.nvim_create_autocmd({ "DirChanged", "BufEnter", "VimEnter" }, {
    callback = function()
      M.find_build_file()
      vim.cmd("redrawstatus")
    end,
  })
  
  -- Create user command
  vim.api.nvim_create_user_command("BuildRun", function()
    M.run_build()
  end, {})
end

return M