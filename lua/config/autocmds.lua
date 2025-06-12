-- config/autocmds.lua
-- Autocommands for various file types and behaviors

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("YankHighlight", { clear = true }),
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
  end,
  desc = "Highlight when yanking (copying) text",
})

-- Close some filetypes with <q>
vim.api.nvim_create_autocmd("FileType", {
  pattern = {
    "PlenaryTestPopup",
    "help",
    "lspinfo",
    "man",
    "notify",
    "qf",
    "spectre_panel",
    "startuptime",
    "tsplayground",
    "neotest-output",
    "checkhealth",
    "neotest-summary",
    "neotest-output-panel",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
  desc = "Close certain filetypes with q",
})


-- Markdown-specific settings
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en"
    vim.opt_local.textwidth = 80
  end,
  desc = "Enable word wrap, spell check, and text width for Markdown",
})

-- Create undo directory if it doesn't exist
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local undo_dir = vim.fn.stdpath('cache') .. '/undo'
    if vim.fn.isdirectory(undo_dir) == 0 then
      vim.fn.mkdir(undo_dir, 'p')
    end
  end,
  desc = "Create undo directory on startup",
})

-- Check for external file changes
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = vim.api.nvim_create_augroup("checktime", { clear = true }),
  command = "checktime",
  desc = "Check if file changed when gaining focus",
})

-- Go to last location when opening a file
vim.api.nvim_create_autocmd("BufReadPost", {
  group = vim.api.nvim_create_augroup("last_loc", { clear = true }),
  callback = function(event)
    local exclude = { "gitcommit" }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].lazyvim_last_loc then
      return
    end
    vim.b[buf].lazyvim_last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
  desc = "Go to last location when opening a file",
})

-- Resize splits if window got resized
vim.api.nvim_create_autocmd({ "VimResized" }, {
  group = vim.api.nvim_create_augroup("resize_splits", { clear = true }),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
  desc = "Resize splits when window is resized",
})

-- Auto-create parent directories when saving
vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("auto_create_dir", { clear = true }),
  callback = function(event)
    if event.match:match("^%w%w+://") then
      return
    end
    local file = vim.loop.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
  desc = "Auto-create parent directories when saving a file",
})

-- Disable auto-comment on new line
vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    vim.opt.formatoptions:remove({ "c", "r", "o" })
  end,
  desc = "Disable auto-comment on new line",
})

-- Terminal settings
vim.api.nvim_create_autocmd("TermOpen", {
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.spell = false
    vim.opt_local.signcolumn = "no"
    vim.cmd("startinsert")
  end,
  desc = "Terminal mode settings",
})

-- Python specific settings
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.opt_local.expandtab = true
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
    vim.opt_local.softtabstop = 4
  end,
  desc = "Python specific settings",
})

-- YAML specific settings
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "yaml", "yml" },
  callback = function()
    vim.opt_local.expandtab = true
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
  end,
  desc = "YAML specific settings",
})

-- JSON specific settings
vim.api.nvim_create_autocmd("FileType", {
  pattern = "json",
  callback = function()
    vim.opt_local.expandtab = true
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
  end,
  desc = "JSON specific settings",
})

-- Auto-save when leaving insert mode or switching buffers
vim.api.nvim_create_autocmd({ "InsertLeave", "BufLeave", "FocusLost" }, {
  group = vim.api.nvim_create_augroup("auto_save", { clear = true }),
  callback = function()
    if vim.bo.modified and not vim.bo.readonly and vim.fn.expand('%') ~= '' and vim.bo.buftype == '' then
      vim.cmd('silent! write')
    end
  end,
  desc = "Auto-save on focus lost or mode change",
})

-- Automatically reload files changed outside of Neovim
vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "CursorHoldI", "FocusGained" }, {
  command = "if mode() != 'c' | checktime | endif",
  pattern = { "*" },
  desc = "Reload files changed outside of Neovim",
})

-- Disable diagnostics in insert mode for better performance
vim.api.nvim_create_autocmd("InsertEnter", {
  callback = function()
    vim.diagnostic.disable(0)
  end,
  desc = "Disable diagnostics in insert mode",
})

vim.api.nvim_create_autocmd("InsertLeave", {
  callback = function()
    vim.diagnostic.enable(0)
  end,
  desc = "Enable diagnostics when leaving insert mode",
})

-- Better quickfix window
vim.api.nvim_create_autocmd("FileType", {
  pattern = "qf",
  callback = function()
    vim.opt_local.wrap = false
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"
    vim.opt_local.colorcolumn = ""
  end,
  desc = "Quickfix window settings",
})

-- Trim trailing whitespace on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  group = vim.api.nvim_create_augroup("trim_whitespace", { clear = true }),
  callback = function()
    local save_cursor = vim.fn.getpos(".")
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.setpos(".", save_cursor)
  end,
  desc = "Remove trailing whitespace on save",
})

-- Auto-close empty unnamed buffers
vim.api.nvim_create_autocmd("BufHidden", {
  group = vim.api.nvim_create_augroup("close_empty_buffers", { clear = true }),
  callback = function(event)
    if vim.bo[event.buf].buftype == "" and vim.fn.bufname(event.buf) == "" and not vim.bo[event.buf].modified then
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(event.buf) then
          vim.api.nvim_buf_delete(event.buf, { force = true })
        end
      end)
    end
  end,
  desc = "Delete empty unnamed buffers when hidden",
})

-- Language-specific: Go
vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function()
    vim.opt_local.expandtab = false
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    -- Go-specific keymaps
    vim.keymap.set('n', '<leader>gt', '<cmd>!go test ./...<cr>', { buffer = true, desc = 'Run Go tests' })
    vim.keymap.set('n', '<leader>gr', '<cmd>!go run .<cr>', { buffer = true, desc = 'Run Go program' })
  end,
  desc = "Go specific settings",
})

-- Language-specific: Rust
vim.api.nvim_create_autocmd("FileType", {
  pattern = "rust",
  callback = function()
    -- Rust-specific keymaps
    vim.keymap.set('n', '<leader>rc', '<cmd>!cargo check<cr>', { buffer = true, desc = 'Cargo check' })
    vim.keymap.set('n', '<leader>rt', '<cmd>!cargo test<cr>', { buffer = true, desc = 'Cargo test' })
    vim.keymap.set('n', '<leader>rr', '<cmd>!cargo run<cr>', { buffer = true, desc = 'Cargo run' })
  end,
  desc = "Rust specific settings",
})

-- Auto-save session on exit
vim.api.nvim_create_autocmd("VimLeavePre", {
  group = vim.api.nvim_create_augroup("auto_session", { clear = true }),
  callback = function()
    if vim.fn.argc() == 0 then -- only save session if no files were opened
      vim.cmd("mksession! ~/.config/nvim/session.vim")
    end
  end,
  desc = "Save session on exit",
})

-- Load project-specific configuration
vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, {
  group = vim.api.nvim_create_augroup("project_config", { clear = true }),
  callback = function()
    local project_config = vim.fn.getcwd() .. "/.nvim.lua"
    if vim.fn.filereadable(project_config) == 1 then
      -- Safely load project config
      local ok, err = pcall(dofile, project_config)
      if not ok then
        vim.notify("Error loading project config: " .. err, vim.log.levels.ERROR)
      else
        vim.notify("Loaded project config from .nvim.lua", vim.log.levels.INFO)
      end
    end
  end,
  desc = "Load project-specific .nvim.lua configuration",
})

-- Help with blink.cmp installation on first run
vim.api.nvim_create_autocmd("User", {
  pattern = "LazyInstall",
  callback = function()
    -- Check if cargo is available for building blink.cmp
    if vim.fn.executable('cargo') == 0 then
      vim.notify("Warning: cargo not found. blink.cmp requires Rust/Cargo to build.\nInstall with: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh", vim.log.levels.WARN)
    end
  end,
  desc = "Check for blink.cmp build dependencies",
})
