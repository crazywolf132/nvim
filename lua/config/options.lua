-- config/options.lua
-- Vim options and settings for optimal development experience

-- General settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'
vim.opt.clipboard = 'unnamedplus'        -- use system clipboard
vim.opt.termguicolors = true            -- true color support
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.expandtab = true                -- use spaces instead of tabs
vim.opt.shiftwidth = 4                  -- indent size
vim.opt.tabstop = 4
vim.opt.signcolumn = 'yes'
vim.opt.updatetime = 250                -- faster updates (for CursorHold, etc.)

-- UI improvements
vim.opt.cursorline = true               -- highlight current line
vim.opt.wrap = false                    -- don't wrap long lines
vim.opt.splitbelow = true               -- open splits downward
vim.opt.splitright = true               -- open splits to the right
vim.opt.scrolloff = 8                   -- keep 8 lines above/below cursor
vim.opt.sidescrolloff = 8               -- keep 8 columns left/right of cursor

-- Search settings
vim.opt.hlsearch = true                 -- highlight search matches
vim.opt.incsearch = true                -- incremental search as you type

-- Backup and undo
vim.opt.backup = false                  -- don't create backup files
vim.opt.writebackup = false             -- don't create backup before overwriting
vim.opt.swapfile = false                -- don't create swap files
vim.opt.undofile = true                 -- enable persistent undo
vim.opt.undodir = vim.fn.stdpath('cache') .. '/undo'  -- set undo directory

-- Performance
vim.opt.lazyredraw = false              -- don't redraw during macros (can cause issues)
vim.opt.timeoutlen = 300                -- time to wait for mapped sequence

-- MacOS specific
vim.opt.shell = '/bin/zsh'              -- ensure shell

-- Global floating window border (Neovim 0.11+ feature)
vim.o.winborder = 'rounded'

-- Folding with treesitter
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
vim.opt.foldenable = false              -- don't fold by default
vim.opt.foldlevel = 99                  -- open most folds by default

-- Better diff experience
vim.opt.diffopt:append({ 'linematch:60' }) -- better diff algorithm

-- Session options
vim.opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }

-- Completion options
vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }
vim.opt.pumheight = 10                  -- limit completion menu height

-- Format options
vim.opt.formatoptions:remove({ 'c', 'r', 'o' }) -- don't auto-comment new lines

-- Better grep
if vim.fn.executable('rg') == 1 then
  vim.opt.grepprg = 'rg --vimgrep --no-heading --smart-case'
  vim.opt.grepformat = '%f:%l:%c:%m'
end

-- Visual feedback improvements
vim.opt.inccommand = 'split'            -- live preview of substitutions
vim.opt.list = true                     -- show invisible characters
vim.opt.listchars = { tab = '▸ ', trail = '·', extends = '…', precedes = '…', nbsp = '␣' }
vim.opt.fillchars = { eob = ' ', fold = ' ', foldopen = 'v', foldsep = ' ', foldclose = '>' }
vim.opt.pumblend = 10                   -- transparency for popup menu
vim.opt.winblend = 10                   -- transparency for floating windows
vim.opt.conceallevel = 2                -- concealing for markdown/json
vim.opt.concealcursor = ''              -- don't conceal on cursor line
vim.opt.cmdheight = 0                   -- hide command line when not used
vim.opt.laststatus = 3                  -- global statusline
vim.opt.splitkeep = 'screen'            -- keep screen position when splitting
vim.opt.shortmess:append({ W = true, I = true, c = true, C = true })
vim.opt.breakindent = true              -- wrapped lines maintain indent
vim.opt.linebreak = true                -- wrap at word boundaries
vim.opt.showbreak = '↪ '                -- indicator for wrapped lines

-- Performance optimizations
vim.opt.synmaxcol = 300                 -- limit syntax highlighting for long lines
vim.opt.redrawtime = 1500               -- time allowed for redrawing (helps with large files)

-- Disable unused providers for faster startup
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0

-- Disable unused built-in plugins
vim.g.loaded_gzip = 1
vim.g.loaded_zip = 1
vim.g.loaded_zipPlugin = 1
vim.g.loaded_tar = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_getscript = 1
vim.g.loaded_getscriptPlugin = 1
vim.g.loaded_vimball = 1
vim.g.loaded_vimballPlugin = 1
vim.g.loaded_2html_plugin = 1
vim.g.loaded_matchit = 1
vim.g.loaded_logiPat = 1
vim.g.loaded_rrhelper = 1
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrwSettings = 1

-- Font settings for GUI Neovim (Neovide, VimR, etc.)
if vim.fn.has('gui_running') == 1 or vim.g.neovide then
  vim.o.guifont = "DankMono Nerd Font:h14"
  -- Enable ligatures
  vim.g.neovide_ligatures = true
end

-- For terminal Neovim, font is controlled by terminal app
-- Note: In terminal Neovim, ligatures depend on your terminal emulator settings
-- For Ghostty, kitty, WezTerm, Alacritty etc., enable ligatures in their configs
