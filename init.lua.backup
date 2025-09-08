--- locals ---
local pack = require('pack')
local o = vim.o
local opt = vim.opt
local g = vim.g
local km = vim.keymap
local autocmd = vim.api.nvim_create_autocmd
local bufnr = vim.api.nvim_get_current_buf()

--- requirements ---
pack.add({
    { src = "nvim-lua/plenary.nvim" }, -- adds plenary required by lots of plugins
    { src = "echasnovski/mini.nvim" }, -- mini.nvim collection
})

--- themes ---
pack.add({
    { src = "WTFox/jellybeans.nvim",         lazy = false }, -- jellybeans
    { src = "folke/tokyonight.nvim",         lazy = true },  -- tokyonight
    { src = "navarasu/onedark.nvim",         lazy = true },  -- onedark
    { src = "shaunsingh/nord.nvim",          lazy = true },  -- nord
    { src = "webhooked/kanso.nvim",          lazy = true },  -- kanso
    { src = "Koalhack/darcubox-nvim",        lazy = true },  -- Darcubox
    { src = "stevedylandev/darkmatter-nvim", lazy = true },  -- Darkmatter
    { src = "mcauley-penney/techbase.nvim",  lazy = true },  -- techbase
    { src = "mitch1000/backpack.nvim", lazy = true }, -- backpack
})

-- require "jellybeans".setup {
--     transparent = true
-- }
require "backpack".setup {
    transparent = true,
    theme = "dark",
    contrast = "medium", -- medium, high, extreme
}
vim.cmd.colorscheme("backpack")
vim.cmd([[ set notermguicolors ]])
-- vim.cmd.colorscheme("jellybeans")

--- lsp ---
pack.add({
    { src = "nvim-lua/plenary.nvim" }, -- adds plenary required by lots of plugins
    {
        src = "nvim-treesitter/nvim-treesitter",
        version = "master",
        build = ":TSUpdate",
        lazy = false
    },                                                                 -- syntax highlighting
    { src = "saghen/blink.cmp",     build = "cargo build --release" }, -- blink completion on master
    { src = "mason-org/mason.nvim" },                                  -- mason for language server install
    { src = "neovim/nvim-lspconfig" },                                 -- core LSP configs
    { src = "williamboman/mason-lspconfig.nvim" },                     -- mason bridge for lspconfig
    { src = "mrcjkb/rustaceanvim" },                                   -- better rust LSP
    { src = "saecki/crates.nvim" },                                    -- better crate helpers
})

local langs = { 'lua_ls', 'gopls', 'jsonls', 'yamlls', 'bashls', 'html', 'cssls', 'pyright', 'emmet_ls' }

-- LSP: install and attach
require('mason').setup {
    ensure_installed = langs,
    pip = {
        upgrade_pip = true,
        install_args = { "--no-cache-dir" },
    }
}
require('mason-lspconfig').setup({ ensure_installed = langs })

-- Basic LSP keymaps so gd uses LSP definition (not Vim's local declaration)
autocmd('LspAttach', {
    callback = function(args)
        local buf = args.buf
        local opts = { buffer = buf, silent = true }
        km.set('n', 'gd', vim.lsp.buf.definition, opts)
        km.set('n', 'gD', vim.lsp.buf.declaration, opts)
        km.set('n', 'gr', vim.lsp.buf.references, opts)
        km.set('n', 'gI', vim.lsp.buf.implementation, opts)
        km.set('n', 'K', vim.lsp.buf.hover, opts)
        km.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
        km.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
        -- LSP group under <leader>l for which-key
        km.set('n', '<leader>lr', vim.lsp.buf.rename, vim.tbl_extend('force', opts, { desc = 'LSP rename' }))
        km.set('n', '<leader>la', vim.lsp.buf.code_action, vim.tbl_extend('force', opts, { desc = 'LSP code action' }))
    end,
})

local lspconfig = require('lspconfig')
local ok_mlsp, mlsp = pcall(require, 'mason-lspconfig')
if ok_mlsp and type(mlsp.setup_handlers) == 'function' then
    mlsp.setup_handlers({
        function(server)
            if server == 'rust_analyzer' then
                -- Let rustaceanvim manage rust-analyzer
                return
            end
            lspconfig[server].setup({})
        end,
        -- Explicit no-op for rust to be extra safe
        ['rust_analyzer'] = function() end,
    })
else
    -- Fallback: directly setup our desired servers
    for _, server in ipairs(langs) do
        if server ~= 'rust_analyzer' then
            lspconfig[server].setup({})
        end
    end
end

-- auto fold imports
-- autocmd("LspNotify", {
--     callback = function(args)
--         if args.data.method == "textDocument/didOpen" then
--             vim.lsp.foldclose('imports', vim.fn.bufwinid(args.buf))
--         end
--     end,
-- })

require "nvim-treesitter.configs".setup {
    ensure_installed = { "lua", "vim", "markdown", "markdown_inline", "bash", "python", "rust", "typescript", "javascript", "css" },
    highlight = {
        enable = true,
    },
}
require "blink.cmp".setup {
    keymap = { preset = "super-tab" },
    appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = 'mono'
    },
    signature = { enabled = true },
    -- Prefer Rust fuzzy engine if present; pinning to a tag allows prebuilt download.
    fuzzy = {
        implementation = 'prefer_rust',
        prebuilt_binaries = {
            -- If you ever see version mismatch warnings, keep this true
            -- or run :PackSync to rebuild at the pinned tag.
            ignore_version_mismatch = true,
        },
    },
}
g.rustaceanvim = {
    -- Plugin configuration
    tools = {
        hover_actions = {
            auto_focus = true,
        }
    },
    -- LSP configuration
    server = {
        default_settings = {
            -- rust-analyzer settings
            ['rust-analyzer'] = {
                -- Enable all features
                cargo = {
                    allFeatures = true,
                    loadOutDirsFromCheck = true,
                    runBuildScripts = true,
                },
                -- Add clippy lints
                check = {
                    command = "clippy",
                    extraArgs = {
                        "--",
                        "-W", "clippy::all",
                        "-W", "clippy::pedantic",
                        "-W", "clippy::nursery",
                        "-A", "clippy::module_name_repetitions",
                        "-A", "clippy::must_use_candidate",
                    },
                },
                procMacro = {
                    enable = true,
                },
                diagnostics = {
                    enable = true,
                    experimental = {
                        enable = true,
                    },
                },
                -- Import settings
                imports = {
                    granularity = {
                        group = "module",
                    },
                    prefix = "self",
                },
                -- Assist settings to help with code actions
                assist = {
                    importEnforceGranularity = true,
                    importPrefix = "self",
                    expressionFillDefault = "todo",
                },
                -- Inlay hints
                inlayHints = {
                    bindingModeHints = {
                        enable = false,
                    },
                    chainingHints = {
                        enable = true,
                    },
                    closingBraceHints = {
                        enable = true,
                        minLines = 25,
                    },
                    closureReturnTypeHints = {
                        enable = "never"
                    },
                    lifetimeElisionHints = {
                        enable = "never",
                        useParameterNames = false,
                    },
                    maxLength = 25,
                    parameterHints = {
                        enable = true,
                    },
                    reborrowHints = {
                        enable = "never",
                    },
                    renderColons = true,
                    typeHints = {
                        enable = true,
                        hideClosureInitialization = false,
                        hideNamedConstructor = false,
                    }
                }
            }
        }
    }
}

require "crates".setup {
    popup = {
        autofocus = true,
        border = "rounded"
    }
}

--- completion ---

--- general ---
require "mini.ai".setup {}
require "mini.comment".setup {
    mappings = {
        comment = "gc",
        comment_line = "gcc",
        comment_visual = "gc",
        textobject = "gc"
    }
}
require "mini.pairs".setup {}
require "mini.surround".setup {
    mappings = {
        add = 'sa',            -- Add surrounding in Normal and Visual modes
        delete = 'sd',         -- Delete surrounding
        find = 'sf',           -- Find surrounding (to the right)
        find_left = 'sF',      -- Find surrounding (to the left)
        highlight = 'sh',      -- Highlight surrounding
        replace = 'sr',        -- Replace surrounding
        update_n_lines = 'sn', -- Update `n_lines`

        suffix_last = 'l',     -- Suffix to search with "prev" method
        suffix_next = 'n',     -- Suffix to search with "next" method
    },
}
require "mini.jump2d".setup {}

--- coding ---
pack.add({
  { src = "supermaven-inc/supermaven-nvim" }, -- ai autocomplete
  { src = "ruifm/gitlinker.nvim" },          -- copy/open Git remote links
})

require "supermaven-nvim".setup {
  keymaps = {
    accept_suggestion = "<Tab>",
    clear_suggestion = "<C-]>",
    accept_word = "<C-j>",
  },
  log_level = "warn",
}

-- Git remote link copier
require('gitlinker').setup({
  opts = {
    -- Copy to system clipboard by default
    action_callback = require('gitlinker.actions').copy_to_clipboard,
    add_current_line_on_normal_mode = true,
    print_url = false,
  },
})


--- ui ---
pack.add({
    { src = "stevearc/oil.nvim" },               -- oil file explorer
    { src = "nvim-tree/nvim-web-devicons" },     -- icons for files
    { src = "benomahony/oil-git.nvim" },         -- git status in oil
    { src = "mluders/comfy-line-numbers.nvim" }, -- Easier relative line numbers
    { src = "folke/twilight.nvim" },             -- Only highlight what you are working on
    { src = "mbbill/undotree" },                 -- better undo tree
    { src = 'akinsho/toggleterm.nvim' },         -- toggle terminal
    { src = 'nvim-lualine/lualine.nvim' }, -- lualine
    { src = "dmtrKovalenko/fff.nvim", lazy = true, build = "cargo build --release" }, -- fastest file searcher.
    { src = "folke/which-key.nvim" },            -- which-key helper
})

require "mini.pick".setup {}
require "oil".setup {
    default_file_explorer = true,
    delete_to_trash = true,
    skip_confirm_for_simple_edits = true,
    cleanup_delay_ms = 100, -- Reduced from 1000ms for better performance
    use_default_keymaps = true,
    view_options = {
        show_hidden = false, -- Changed to false for better performance
        is_always_hidden = function(name, bufnr)
            return vim.startswith(name, ".git")
        end,
    },
    win_options = {
        signcolumn = "auto"
    },
    keymaps = {
        ["<C-s>"] = {
            callback = function()
                require("oil").save()
            end,
            mode = "n",
            desc = "Save changes in Oil"
        },
    }
}
require "twilight".setup {
    dimming = {
        alpha = 0.3, -- amount of dimming
        -- we try to get the foreground from the hightlight groups or fallback color
        color = { "Normal", "#ffffff" },
        term_bg = "#000000", -- if guibg=NONE, this will be used to calculate text color
        inactive = true,     -- when true, other windows will be fully dimmed (unless they contain the same buffer)
    },
    context = 7,             -- the amount of lines we will try and show around the current line
    treesitter = true,       -- use treesitter when available for the filetype
    -- treesitter is used to automatically expand the visible text,
    -- but you can further control the types of nodes that should always be fully expanded
    expand = { -- for treesitter, we always try to expand to the top-most ancestor with these types
        "function",
        "method",
        "table",
        "if_statement",
    },
    exclude = {}, -- exclude these filetypes
}
require "toggleterm".setup {
    open_mapping = [[<C-\>]],
    hide_numbers = true,
    shade_terminal = true,
    shade_filetypes = {},
    shading_factor = 2,
    start_in_insert = true,
    insert_mappings = true,
    terminal_mappings = true,
    persist_size = true,
    persist_mode = true,
    direction = 'float',
    close_on_exit = true,
    shell = vim.o.shell,
    auto_scroll = true,
    float_opts = {
        border = 'curved',
        width = function()
            return math.floor(o.columns * 0.9)
        end,
        height = function()
            return math.floor(o.lines * 0.9)
        end,
        winblend = 3,
    },
    winbar = {
        enabled = false,
        name_formatter = function(term)
            return term.name
        end
    },
}

-- Simple command to pull updates and run build hooks
vim.api.nvim_create_user_command('PackSync', function()
  require('pack').update_all()
end, {})

local Terminal = require('toggleterm.terminal').Terminal
local lazygit = Terminal:new({
    cmd = "lazygit",
    dir = "git_dir",
    direction = "float",
    float_opts = {
        border = "rounded",
    },
    on_open = function(term)
        vim.cmd("startinsert!")
        km.set('n', 'q', '<cmd>close<CR>', { buffer = term.bufnr })
    end,
    on_close = function(_)
        vim.cmd("startinsert!")
    end,
})

function _LAZYGIT_TOGGLE()
    lazygit:toggle()
end

require 'lualine'.setup {
  theme = 'auto',
}

-- which-key: show keybinding hints
pcall(function()
  local wk = require('which-key')
  if type(wk.setup) == 'function' then
    wk.setup({
      plugins = { spelling = true },
      window = { border = 'rounded' },
      show_help = true,
    })
  end

  -- Register common groups; mapping desc will be read automatically
  if type(wk.add) == 'function' then
    wk.add({
      { '<leader>g', group = 'Git' },
      { '<leader>z', group = 'Folds' },
      { '<leader>w', group = 'Windows' },
      { '<leader>t', group = 'Toggle/Tools' },
      { '<leader>l', group = 'LSP' },
    })
  elseif type(wk.register) == 'function' then
    wk.register({
      g = { name = 'Git' },
      z = { name = 'Folds' },
      w = { name = 'Windows' },
      t = { name = 'Toggle/Tools' },
      l = { name = 'LSP' },
    }, { prefix = '<leader>' })
  end
end)
--- smart save helper ---
local function smart_save()
  local buf = vim.api.nvim_get_current_buf()
  local bo = vim.bo[buf]

  -- Skip non-file buffers politely
  if bo.buftype ~= '' then
    if bo.buftype == 'terminal' or bo.buftype == 'nofile' or bo.buftype == 'help' or bo.buftype == 'quickfix' or bo.buftype == 'prompt' then
      vim.notify('Nothing to save for this buffer', vim.log.levels.INFO)
      return
    end
  end

  if not bo.modifiable then
    vim.notify('Buffer is not modifiable', vim.log.levels.WARN)
    return
  end

  -- Unnamed buffers: user opted out of prompting; skip
  local name = vim.api.nvim_buf_get_name(buf)
  if name == '' then
    vim.notify('No filename. Skipping save.', vim.log.levels.INFO)
    return
  end

  -- Ensure parent dir exists for named buffers
  local dir = vim.fn.fnamemodify(name, ':p:h')
  if dir ~= '' and vim.fn.isdirectory(dir) == 0 then
    vim.fn.mkdir(dir, 'p')
  end
  -- Prefer :update (write only if changed)
  local ok, err = pcall(vim.cmd.update)
  if ok then return end
  -- Permission denied or other error: try sudo tee fallback
  local msg = tostring(err or '')
  if msg:match('E212') or msg:lower():match('permission') then
    local tmp = vim.fn.tempname()
    -- Write to a temp file first to avoid clobbering
    local wrote_tmp = pcall(vim.cmd.write, vim.fn.fnameescape(tmp))
    if wrote_tmp then
      local cmd = string.format('silent keepalt execute "!sudo tee %s > /dev/null < %s"', vim.fn.shellescape(name), vim.fn.shellescape(tmp))
      vim.cmd(cmd)
      -- Reload from disk to pick up correct perms/mtime
      pcall(vim.cmd.edit)
      vim.fn.delete(tmp)
      return
    end
  end
  vim.notify('Save failed: ' .. msg, vim.log.levels.ERROR)
end
--- settings ---
-- line numbers
o.number = true         -- show line numbers
o.relativenumber = true -- show relative line numbers

-- tabs & indentation
o.tabstop = 2       -- spaces per tab
o.shiftwidth = 2    -- spaces per tab
o.expandtab = true  -- use spaces instead of tabs
o.autoindent = true -- copy indent from current line

-- line wrapping
o.wrap = false

-- search settings
o.ignorecase = true -- ignore case when searching
o.smartcase = true  -- if there is mixed case in the search, it will use case-sensitive

-- cursor line
o.cursorline = true -- highlight the current cursor line

-- appearance
o.termguicolors = true -- enable 24bit colors
o.background = "dark"  -- colorschemes with light or dark will be asked to use dark
o.signcolumn = "yes"   -- show sign column so that text doesn't shift around

-- backspace
o.backspace = "indent,eol,start" -- allow backspacing on indent, end of line, or insert mode start position

-- clipboard
o.clipboard = "unnamedplus" -- use system clipboard

-- split windows
o.splitright = true -- split vertical windows right
o.splitbelow = true -- split horizontal windows below

-- turn off swapfiles
o.swapfile = false

o.updatetime = 100
o.hlsearch = false
o.incsearch = true

o.scrolloff = 8 -- Reduced from 999 for better performance
o.winborder = "rounded"

-- setting leaderkey
g.mapleader = " "
g.maplocalleader = "\\"

-- fixing the font
g.have_nerd_font = true

-- show the mode or not
o.showmode = false -- don't show mode since we have a statusline

-- mouse mode
o.mouse = 'a' -- enable mouse mode

-- undofile
o.undofile = true

-- save confirm
o.confirm = true -- confirm before quit

-- netrw
g.netrw_browse_split = 0 -- disabling splitting
g.netrw_banner = 0       -- removing the banner
g.netrw_winsize = 25     -- setting window size
-- disable netrw
g.loaded_netrw = 1
g.loaded_netrwPlugin = 1

-- Folding: prefer Treesitter, fallback to indent if no parser/feature
opt.foldenable = true          -- ensure folds are active
opt.foldlevel = 99             -- keep folds open by default, but available
opt.foldlevelstart = 99

local function apply_folds_for(win, buf)
  win = win or vim.api.nvim_get_current_win()
  buf = buf or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_win_is_valid(win) then return end

  local ft = vim.bo[buf].filetype
  local has_parsers, parsers = pcall(require, 'nvim-treesitter.parsers')
  local has_new = type(vim.treesitter) == 'table' and type(vim.treesitter.foldexpr) == 'function'

  if has_parsers and parsers.has_parser(ft) then
    pcall(vim.api.nvim_set_option_value, 'foldmethod', 'expr', { win = win })
    if has_new then
      pcall(vim.api.nvim_set_option_value, 'foldexpr', 'v:lua.vim.treesitter.foldexpr()', { win = win })
    else
      pcall(vim.api.nvim_set_option_value, 'foldexpr', 'nvim_treesitter#foldexpr()', { win = win })
    end
  else
    pcall(vim.api.nvim_set_option_value, 'foldmethod', 'indent', { win = win })
    pcall(vim.api.nvim_set_option_value, 'foldexpr', '', { win = win })
  end
end

-- Ensure folds are applied whenever a buffer gets a window or filetype is set
autocmd('BufWinEnter', {
  callback = function(args)
    apply_folds_for(vim.api.nvim_get_current_win(), args.buf)
  end,
})
autocmd('FileType', {
  callback = function(args)
    apply_folds_for(vim.api.nvim_get_current_win(), args.buf)
  end,
})

--- keymaps ---

km.set('n', '<leader>o', ':update<CR> :source<CR>', { silent = true, desc = "reload config" })
km.set('n', '<leader>qq', '<cmd>qa<CR>', { silent = true, desc = "quit all" })
km.set('n', '<leader>lf', vim.lsp.buf.format, { desc = 'format file' })

km.set('n', '<leader>e', ':Oil<CR>', { silent = true, desc = "Open file explorer" })
-- km.set('n', '<leader><leader>', ':Pick files<CR>', { silent = true, desc = "find files" })
km.set('n', '<leader><leader>', function() require('fff').find_files() end, { silent = true, desc = "find files" })
km.set('n', 'ff', function() require('fff').find_files() end, { silent = true, desc = "find files" })
km.set('n', '<leader>/', ':Pick grep_live<CR>', { silent = true, desc = "find in files" })
km.set('n', '<leader>?', ':Pick help<CR>', { silent = true, desc = "search help" })
km.set('n', '<leader>b', ':Pick buffers<CR>', { silent = true, desc = "search buffers" })
km.set('n', '<leader>u', ':lua vim.pack.update(nil, { force = true })<CR>', { silent = true, desc = "update plugins" })

km.set('n', '<leader>U', ':UndotreeToggle<CR>', { silent = true, desc = "undo tree" })

-- folding convenience (mirrors built-in z-keys behind <leader>z*)
km.set('n', '<leader>zz', 'za', { desc = 'toggle fold' })
km.set('n', '<leader>zo', 'zO', { desc = 'open fold recursively' })
km.set('n', '<leader>zc', 'zC', { desc = 'close fold recursively' })
km.set('n', '<leader>zR', 'zR', { desc = 'open all folds' })
km.set('n', '<leader>zM', 'zM', { desc = 'close all folds' })

-- window management
km.set('n', '<leader>|', '<C-w>v', { silent = true, desc = "split vertically" })
km.set('n', '<leader>wv', '<C-w>v', { silent = true, desc = "split vertically" })
km.set('n', '<leader>ws', '<C-w>s', { silent = true, desc = "split horizontally" })

-- window navigation
km.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
km.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
km.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
km.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- ui
km.set('n', '<leader>tt', ":Twilight<CR>", { desc = "Toggle twilight" })
km.set("n", "<leader>gg", "<cmd>lua _LAZYGIT_TOGGLE()<CR>", { desc = "Toggle lazygit" })
km.set('n', '<leader>ta', "<cmd>lua require('supermaven-nvim.api').toggle()<CR>", { desc = "toggle ai"})

-- GitHub/Git remote permalink keymaps via gitlinker
km.set('n', '<leader>gy', function()
  require('gitlinker').get_buf_range_url('n', { add_current_line_on_normal_mode = false })
end, { desc = 'Copy Git link (file only)' })
km.set('n', '<leader>gY', function()
  require('gitlinker').get_buf_range_url('n', { add_current_line_on_normal_mode = true })
end, { desc = 'Copy Git link (line)' })
km.set('v', '<leader>gY', function()
  require('gitlinker').get_buf_range_url('v')
end, { desc = 'Copy Git link (selection)' })

-- Disable terminal flow control to allow Ctrl+S (add `stty -ixon` to your shell config like .zshrc or .bashrc)
-- Best effort: disable XON/XOFF so <C-s>/<C-q> reach Neovim (tmux or not)
pcall(function()
  if vim.fn.has('unix') == 1 then
    -- Only attempt when attached to a tty; errors are ignored
    vim.fn.system({ 'stty', '-ixon' })
  end
end)

-- Smarter save in all common modes
local function map_save(m, lhs)
  km.set(m, lhs, function()
    -- Preserve selection in visual/select, return to mode in terminal
    local mode = vim.api.nvim_get_mode().mode
    if mode == 't' then
      vim.cmd('stopinsert')
    end
    smart_save()
    if mode == 't' then
      vim.cmd('startinsert')
    elseif mode == 'v' or mode == 'V' or mode == string.char(22) then -- visual block is <C-v>
      vim.cmd('silent! normal! gv')
    end
  end, { silent = true, noremap = true, desc = 'Smart save' })
end

for _, m in ipairs({ 'n', 'i', 'v', 'x', 's', 'o', 't', 'c' }) do
  map_save(m, '<C-s>')
  map_save(m, '<D-s>') -- In GUIs/terminals that send <D-s>
end
