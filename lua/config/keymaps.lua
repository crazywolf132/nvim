-- config/keymaps.lua
-- Global key mappings including macOS shortcuts

local map = vim.keymap.set

-- Leader key is set in init.lua

-- Save shortcuts (macOS compatible)
map({'n','v'}, '<C-s>', '<cmd>w<CR>', { desc = 'Save file' })
map('i', '<C-s>', '<cmd>w<CR>', { desc = 'Save file' })  -- stays in insert mode
map({'n','v'}, '<D-s>', '<cmd>w<CR>', { desc = 'Save file (Cmd+S)' })
map('i', '<D-s>', '<cmd>w<CR>', { desc = 'Save file (Cmd+S)' })  -- stays in insert mode

-- Save without formatting (useful for Rust to skip clippy/import cleanup)
local function save_without_format()
  vim.b.save_without_format = true
  vim.cmd('write')
end

map({'n','v'}, '<C-S-s>', save_without_format, { desc = 'Save without formatting' })
map('i', '<C-S-s>', save_without_format, { desc = 'Save without formatting' })
map({'n','v'}, '<D-S-s>', save_without_format, { desc = 'Save without formatting (Cmd+Shift+S)' })
map('i', '<D-S-s>', save_without_format, { desc = 'Save without formatting (Cmd+Shift+S)' })

-- Better up/down (handles wrapped lines)
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Move to window using the <ctrl> hjkl keys
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Resize window using <ctrl> arrow keys
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

-- Move Lines
map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move line down" })
map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move line up" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move line down" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move line up" })
map("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })
map("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })

-- Clear search with <esc>
map({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and clear hlsearch" })

-- Better indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Quit
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })

-- New file
map("n", "<leader>fn", "<cmd>enew<cr>", { desc = "New file" })

-- Lazy
map("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy" })

-- Terminal (enhanced by toggleterm plugin)
map("t", "<esc><esc>", "<c-\\><c-n>", { desc = "Enter Normal Mode" })

-- Windows
map("n", "<leader>ww", "<C-W>p", { desc = "Other window" })
map("n", "<leader>wd", "<C-W>c", { desc = "Delete window" })
map("n", "<leader>w-", "<C-W>s", { desc = "Split window below" })
map("n", "<leader>w|", "<C-W>v", { desc = "Split window right" })

-- Quick split shortcuts
map("n", "<leader>|", "<C-W>v", { desc = "Split window right" })

-- Tabs
map("n", "<leader><tab>l", "<cmd>tablast<cr>", { desc = "Last Tab" })
map("n", "<leader><tab>f", "<cmd>tabfirst<cr>", { desc = "First Tab" })
map("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "New Tab" })
map("n", "<leader><tab>]", "<cmd>tabnext<cr>", { desc = "Next Tab" })
map("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close Tab" })
map("n", "<leader><tab>[", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })

-- FZF-Lua keymaps (faster alternative to Telescope)
map('n', '<leader><leader>', '<cmd>FzfLua files<CR>', { desc = 'Find Files (Quick)' })
map('n', '<leader>ff', '<cmd>FzfLua files<CR>', { desc = 'Find Files' })
map('n', '<leader>fg', '<cmd>FzfLua live_grep<CR>', { desc = 'Live Grep' })
map('n', '<leader>fb', '<cmd>FzfLua buffers<CR>', { desc = 'List Buffers' })
map('n', '<leader>fh', '<cmd>FzfLua help_tags<CR>', { desc = 'Search Help' })
map('n', '<leader>fr', '<cmd>FzfLua oldfiles<CR>', { desc = 'Recent Files' })
map('n', '<leader>fc', '<cmd>FzfLua commands<CR>', { desc = 'Commands' })
map('n', '<leader>fk', '<cmd>FzfLua keymaps<CR>', { desc = 'Keymaps' })
map('n', '<leader>fd', '<cmd>FzfLua diagnostics_document<CR>', { desc = 'Document Diagnostics' })
map('n', '<leader>fD', '<cmd>FzfLua diagnostics_workspace<CR>', { desc = 'Workspace Diagnostics' })

-- Git keymaps (will be available when fugitive loads)
map('n', '<leader>gg', '<cmd>Git<CR>', { desc = 'Git status (Fugitive)' })

-- Markdown keymaps (will be available when markdown-preview loads)
map('n', '<leader>mp', '<cmd>MarkdownPreview<CR>', { desc = 'Markdown Preview (browser)' })
map('n', '<leader>mc', '<cmd>MarkdownPreviewStop<CR>', { desc = 'Close Markdown Preview' })
map('n', '<leader>mg', '<cmd>Glow<CR>', { desc = 'Markdown Preview (Glow terminal)' })

-- Additional useful keymaps
map('n', '<leader>bd', '<cmd>bdelete<cr>', { desc = 'Delete Buffer' })
map('n', '<leader>bn', '<cmd>bnext<cr>', { desc = 'Next Buffer' })
map('n', '<leader>bp', '<cmd>bprevious<cr>', { desc = 'Previous Buffer' })

-- Mason and LSP management
map('n', '<leader>cm', '<cmd>Mason<cr>', { desc = 'Mason Package Manager' })
map('n', '<leader>ci', '<cmd>LspInfo<cr>', { desc = 'LSP Info' })

-- Diagnostics
map('n', '<leader>cd', '<cmd>lua vim.diagnostic.open_float()<cr>', { desc = 'Show Line Diagnostics' })
map('n', '<leader>cq', '<cmd>lua vim.diagnostic.setloclist()<cr>', { desc = 'Diagnostics to Location List' })

-- Quick fix list
map('n', '<leader>co', '<cmd>copen<cr>', { desc = 'Open Quickfix List' })
map('n', '<leader>cc', '<cmd>cclose<cr>', { desc = 'Close Quickfix List' })
map('n', '[q', '<cmd>cprevious<cr>', { desc = 'Previous Quickfix Item' })
map('n', ']q', '<cmd>cnext<cr>', { desc = 'Next Quickfix Item' })

-- Location list
map('n', '<leader>lo', '<cmd>lopen<cr>', { desc = 'Open Location List' })
map('n', '<leader>lc', '<cmd>lclose<cr>', { desc = 'Close Location List' })
map('n', '[l', '<cmd>lprevious<cr>', { desc = 'Previous Location Item' })
map('n', ']l', '<cmd>lnext<cr>', { desc = 'Next Location Item' })

-- Search and replace
map('n', '<leader>sr', ':%s/<C-r><C-w>//g<Left><Left>', { desc = 'Replace word under cursor' })
map('v', '<leader>sr', '"hy:%s/<C-r>h//g<Left><Left>', { desc = 'Replace selected text' })

-- Toggle settings
map('n', '<leader>uw', '<cmd>set wrap!<cr>', { desc = 'Toggle word wrap' })
map('n', '<leader>us', '<cmd>set spell!<cr>', { desc = 'Toggle spell check' })
map('n', '<leader>ul', '<cmd>set number!<cr>', { desc = 'Toggle line numbers' })
map('n', '<leader>ur', '<cmd>set relativenumber!<cr>', { desc = 'Toggle relative numbers' })
map('n', '<leader>uh', '<cmd>set hlsearch!<cr>', { desc = 'Toggle search highlight' })

-- Better code folding (using native commands)
map('n', 'zR', 'zR', { desc = 'Open all folds' })
map('n', 'zM', 'zM', { desc = 'Close all folds' })

-- Smart splits navigation (if using tmux or wezterm)
map('n', '<C-h>', '<C-w>h', { desc = 'Go to left window' })
map('n', '<C-j>', '<C-w>j', { desc = 'Go to lower window' })
map('n', '<C-k>', '<C-w>k', { desc = 'Go to upper window' })
map('n', '<C-l>', '<C-w>l', { desc = 'Go to right window' })

-- Yank to system clipboard
map({'n', 'v'}, '<leader>y', '"+y', { desc = 'Yank to system clipboard' })
map('n', '<leader>Y', '"+Y', { desc = 'Yank line to system clipboard' })
map({'n', 'v'}, '<leader>p', '"+p', { desc = 'Paste from system clipboard' })
map({'n', 'v'}, '<leader>P', '"+P', { desc = 'Paste before from system clipboard' })

-- Delete without yanking
map({'n', 'v'}, '<leader>d', '"_d', { desc = 'Delete without yanking' })

-- Keep cursor centered when scrolling
map('n', '<C-d>', '<C-d>zz', { desc = 'Scroll down and center' })
map('n', '<C-u>', '<C-u>zz', { desc = 'Scroll up and center' })
map('n', 'n', 'nzzzv', { desc = 'Next search result and center' })
map('n', 'N', 'Nzzzv', { desc = 'Previous search result and center' })

-- Join lines without moving cursor
map('n', 'J', 'mzJ`z', { desc = 'Join lines without moving cursor' })

-- Undo break points
map('i', ',', ',<c-g>u')
map('i', '.', '.<c-g>u')
map('i', '!', '!<c-g>u')
map('i', '?', '?<c-g>u')

-- Select all
map('n', '<C-a>', 'ggVG', { desc = 'Select all' })
map('i', '<C-a>', '<Esc>ggVG', { desc = 'Select all' })
map('v', '<C-a>', '<Esc>ggVG', { desc = 'Select all' })

-- Redo
map('n', '<C-r>', '<C-r>', { desc = 'Redo' })
map('i', '<C-r>', '<Esc><C-r>a', { desc = 'Redo' })

-- Better line navigation
map('n', 'H', '^', { desc = 'Move to first non-blank character' })
map('n', 'L', '$', { desc = 'Move to end of line' })
map('v', 'H', '^', { desc = 'Move to first non-blank character' })
map('v', 'L', '$', { desc = 'Move to end of line' })

-- Buffer management (Doom Emacs style)
map('n', '<leader>bb', '<cmd>FzfLua buffers<cr>', { desc = 'List buffers (buffer switcher)' })
map('n', '<leader>b<leader>', '<cmd>b#<cr>', { desc = 'Toggle to last buffer' })
map('n', '<leader>bD', '<cmd>%bd|e#|bd#<cr>', { desc = 'Delete all buffers except current' })

-- Copy file paths
map('n', '<leader>fp', '<cmd>let @+ = expand("%:p")<cr>', { desc = 'Copy full file path' })
map('n', '<leader>fP', '<cmd>let @+ = expand("%:~:.")<cr>', { desc = 'Copy relative file path' })
map('n', '<leader>fn', '<cmd>let @+ = expand("%:t")<cr>', { desc = 'Copy file name' })

-- Open current file in finder (macOS)
map('n', '<leader>fo', '<cmd>!open "%:p:h"<cr>', { desc = 'Open file location in Finder' })

-- Quick macro execution
map('n', 'Q', '@q', { desc = 'Execute macro in register q' })
map('v', 'Q', ':norm @q<cr>', { desc = 'Execute macro on selection' })

-- Quick substitution
map('n', '<leader>s*', [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = 'Replace word under cursor (whole word)' })

-- Better marks
map('n', "'", '`', { desc = 'Jump to mark (exact position)' })
map('n', '`', "'", { desc = 'Jump to mark (beginning of line)' })

-- Quickfix improvements
map('n', '<leader>cj', '<cmd>cnext<cr>zz', { desc = 'Next quickfix and center' })
map('n', '<leader>ck', '<cmd>cprev<cr>zz', { desc = 'Previous quickfix and center' })

-- Smart home key
map({'n', 'v'}, '0', "getline('.')[0:col('.')-2] =~# '^\\s*$' ? '0' : '^'", { expr = true, desc = 'Smart home' })

-- Toggle inlay hints
map('n', '<leader>ui', function()
  if vim.lsp.inlay_hint then
    local ok, enabled = pcall(vim.lsp.inlay_hint.is_enabled)
    if ok then
      pcall(vim.lsp.inlay_hint.enable, not enabled)
      vim.notify("Inlay hints " .. (enabled and "disabled" or "enabled"), vim.log.levels.INFO)
    else
      vim.notify("Inlay hints not available", vim.log.levels.WARN)
    end
  else
    vim.notify("Inlay hints not supported in this Neovim version", vim.log.levels.WARN)
  end
end, { desc = 'Toggle inlay hints' })

-- Session management
map('n', '<leader>qs', '<cmd>source ~/.config/nvim/session.vim<cr>', { desc = 'Restore last session' })

-- Reload Neovim configuration
map('n', '<leader>R', function()
  -- Clear loaded modules cache
  for name, _ in pairs(package.loaded) do
    if name:match('^config') or name:match('^plugins') then
      package.loaded[name] = nil
    end
  end
  
  -- Source the init.lua file
  dofile(vim.env.MYVIMRC)
  
  -- Sync plugins if needed
  vim.cmd('Lazy sync')
  
  vim.notify("Configuration reloaded!", vim.log.levels.INFO)
end, { desc = 'Reload Neovim configuration' })

-- Project-wide search and replace
map('n', '<leader>sR', function()
  local query = vim.fn.input('Search: ')
  if query ~= '' then
    local replace = vim.fn.input('Replace with: ')
    vim.cmd('cdo s/' .. query .. '/' .. replace .. '/g | update')
  end
end, { desc = 'Search and replace in quickfix' })

-- Check external dependencies
map('n', '<leader>ch', function()
  local deps = {
    { cmd = 'rg', name = 'ripgrep', desc = 'Required for live grep and file search' },
    { cmd = 'fd', name = 'fd', desc = 'Optional: faster file finding' },
    { cmd = 'bat', name = 'bat', desc = 'Optional: syntax highlighting in previews' },
    { cmd = 'delta', name = 'delta', desc = 'Optional: better git diffs' },
    { cmd = 'fzf', name = 'fzf', desc = 'Required for fzf-lua fuzzy finding' },
    { cmd = 'cargo', name = 'cargo', desc = 'Required for building blink.cmp (Rust)' },
  }
  
  local results = {}
  for _, dep in ipairs(deps) do
    local found = vim.fn.executable(dep.cmd) == 1
    table.insert(results, string.format('%s %s - %s', 
      found and '✓' or '✗', 
      dep.name, 
      dep.desc
    ))
  end
  
  vim.notify(table.concat(results, '\n'), vim.log.levels.INFO, { title = 'Dependency Check' })
end, { desc = 'Check external dependencies' })

