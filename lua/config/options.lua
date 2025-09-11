local opt = vim.opt

-- UI
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.termguicolors = true
opt.cursorline = true
opt.wrap = false
opt.list = true
opt.listchars = { tab = "▸ ", trail = "·", extends = "⟩", precedes = "⟨" }
opt.scrolloff = 6
opt.sidescrolloff = 8
opt.splitbelow = true
opt.splitright = true
opt.fillchars:append({ diff = "╱", eob = " " })

-- Search
opt.ignorecase = true
opt.smartcase = true

-- Editing
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true
opt.breakindent = true
opt.copyindent = true
opt.preserveindent = true
opt.virtualedit = "block"

-- Behavior
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.undofile = true
opt.swapfile = false
opt.updatetime = 200
opt.timeoutlen = 400
opt.completeopt = { "menu", "menuone", "noselect" }
opt.conceallevel = 2
opt.inccommand = "split"

-- Folds: open by default, rely on Treesitter when available
opt.foldenable = false
opt.foldlevel = 99
opt.foldlevelstart = 99

