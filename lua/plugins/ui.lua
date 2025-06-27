-- plugins/ui.lua
-- UI plugins (statusline, colorscheme, etc.)

return {
    -- Colorschemes
    {
        'folke/tokyonight.nvim',
        priority = 1000,
        config = function()
            require('tokyonight').setup({
                style = 'night',
                transparent = false,
                terminal_colors = true,
            })
        end
    },

    {
        'dgox16/oldworld.nvim',
        priority = 1000,
        config = function()
            require('oldworld').setup({
                terminal_colors = true,
                variant = "default", -- default, oled, cooler
                styles = {
                    comments = {},
                    keywords = {},
                    identifiers = {},
                    functions = {},
                    variables = {},
                    booleans = {},
                },
                integrations = {
                    alpha = true,
                    cmp = true,
                    flash = true,
                    gitsigns = true,
                    hop = false,
                    indent_blankline = true,
                    lazy = true,
                    lsp = true,
                    markdown = true,
                    mason = true,
                    navic = false,
                    neo_tree = false,
                    neogit = false,
                    neorg = false,
                    noice = true,
                    notify = true,
                    rainbow_delimiters = true,
                    telescope = true,
                    treesitter = true,
                },
                highlight_overrides = {}
            })
        end
    },

    {
        'nyoom-engineering/oxocarbon.nvim',
        priority = 1000,
        config = function()
            -- vim.opt.background = "dark" -- set this to dark or light

            -- Set the colorscheme (change this to switch themes)
            -- vim.cmd('colorscheme oxocarbon')
            -- Alternative themes:
            -- vim.cmd('colorscheme oldworld')
            -- vim.cmd('colorscheme tokyonight-night')
        end
    },

    {
        "ilof2/posterpole.nvim",
        priority = 1000,
        lazy = false,
        config = function()
            local posterpole = require("posterpole")

            posterpole.setup({
                transparent = true
            })
            vim.cmd('colorscheme posterpole')

            -- This function creates a scheduled task, which will reload the theme every hour
            -- Without "setup_adaptive" adaptive brightness will be set only after every restart
            posterpole.setup_adaptive()
        end
    }

    -- Status line
    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        config = function()
            require('lualine').setup {
                options = {
                    theme = 'tokyonight',
                    globalstatus = true,
                    component_separators = '|',
                    section_separators = '',
                },
                sections = {
                    lualine_a = { 'mode' },
                    lualine_b = { 'branch', 'diff' },
                    lualine_c = { { 'filename', path = 1 } },
                    lualine_x = {
                        -- Build status component
                        {
                            function()
                                local build_status = require('custom.build-status')
                                local icon, _ = build_status.get_display()
                                return icon
                            end,
                            color = function()
                                local build_status = require('custom.build-status')
                                local _, color = build_status.get_display()
                                return color
                            end,
                            cond = function()
                                local build_status = require('custom.build-status')
                                return build_status.current_state ~= build_status.states.NOT_FOUND
                            end,
                        },
                        'diagnostics',
                        'encoding',
                        'filetype'
                    },
                    lualine_y = { 'progress' },
                    lualine_z = { 'location' }
                }
            }
        end
    },

    -- Which-key for discoverability
    {
        'folke/which-key.nvim',
        event = 'VeryLazy',
        config = function()
            local wk = require('which-key')

            wk.setup({
                preset = "modern",
                delay = 300,
                plugins = {
                    marks = true,
                    registers = true,
                    spelling = {
                        enabled = true,
                        suggestions = 20,
                    },
                },
            })

            -- Register key groups and labels
            wk.add({
                -- File operations (FZF-Lua)
                { "<leader>f",          group = "Find/File" },
                { "<leader>ff",         desc = "Find Files" },
                { "<leader>fg",         desc = "Live Grep" },
                { "<leader>fb",         desc = "List Buffers" },
                { "<leader>fh",         desc = "Search Help" },
                { "<leader>fr",         desc = "Recent Files" },
                { "<leader>fc",         desc = "Commands" },
                { "<leader>fk",         desc = "Keymaps" },
                { "<leader>fd",         desc = "Document Diagnostics" },
                { "<leader>fD",         desc = "Workspace Diagnostics" },
                { "<leader>fn",         desc = "New File" },
                { "<leader>fp",         desc = "Copy full file path" },
                { "<leader>fP",         desc = "Copy relative file path" },
                { "<leader>fo",         desc = "Open file location in Finder" },

                -- File explorer
                { "<leader>e",          desc = "File explorer (floating)" },
                { "-",                  desc = "Open parent directory" },

                -- Aerial (Code structure)
                { "<leader>a",          desc = "Aerial (Symbols)" },
                { "<leader>A",          desc = "Aerial Navigation" },
                { "{",                  desc = "Previous Symbol" },
                { "}",                  desc = "Next Symbol" },

                -- Testing (Neotest)
                { "<leader>t",          group = "Test" },
                { "<leader>tt",         desc = "Run Nearest Test" },
                { "<leader>tf",         desc = "Run File Tests" },
                { "<leader>ta",         desc = "Run All Tests" },
                { "<leader>ts",         desc = "Toggle Test Summary" },
                { "<leader>to",         desc = "Show Test Output" },
                { "<leader>tO",         desc = "Toggle Test Output Panel" },
                { "<leader>tS",         desc = "Stop Test" },
                { "<leader>tw",         desc = "Toggle Test Watch" },

                -- Search enhancements
                { "<leader>s",          group = "Search" },
                { "<leader>st",         desc = "Search TODOs" },
                { "<leader>sT",         desc = "Search TODO/FIX/FIXME" },
                { "<leader>sR",         desc = "Search and replace in quickfix" },
                { "<leader>sr",         desc = "Replace word under cursor" },


                -- Trouble (Better diagnostics)
                { "<leader>x",          group = "Trouble" },
                { "<leader>xx",         desc = "Diagnostics (Trouble)" },
                { "<leader>xX",         desc = "Buffer Diagnostics (Trouble)" },
                { "<leader>xL",         desc = "Location List (Trouble)" },
                { "<leader>xQ",         desc = "Quickfix List (Trouble)" },

                -- Todo navigation
                { "]t",                 desc = "Next todo comment" },
                { "[t",                 desc = "Previous todo comment" },

                -- Git operations
                { "<leader>g",          group = "Git" },
                { "<leader>gg",         desc = "Git Status" },

                -- Harpoon navigation
                { "<leader>h",          group = "Harpoon" },
                { "<leader>ha",         desc = "Add to Harpoon" },
                { "<leader>hh",         desc = "Toggle Harpoon menu" },
                { "<leader>hp",         desc = "Previous Harpoon" },
                { "<leader>hn",         desc = "Next Harpoon" },
                { "<leader>hr",         desc = "Remove from Harpoon" },
                { "<leader>hc",         desc = "Clear Harpoon list" },

                -- Quick Harpoon access
                { "<leader>1",          desc = "Harpoon file 1" },
                { "<leader>2",          desc = "Harpoon file 2" },
                { "<leader>3",          desc = "Harpoon file 3" },
                { "<leader>4",          desc = "Harpoon file 4" },
                { "<leader>5",          desc = "Harpoon file 5" },
                { "<leader><Tab>",      desc = "Cycle Harpoon files" },

                -- Alt + number for super quick access
                { "<M-1>",              desc = "Quick: Harpoon 1" },
                { "<M-2>",              desc = "Quick: Harpoon 2" },
                { "<M-3>",              desc = "Quick: Harpoon 3" },
                { "<M-4>",              desc = "Quick: Harpoon 4" },
                { "<M-5>",              desc = "Quick: Harpoon 5" },

                -- Git hunks (available when gitsigns loads)
                { "<leader>G",          group = "Git Hunks" },
                { "<leader>Gs",         desc = "Stage Hunk" },
                { "<leader>Gu",         desc = "Undo Stage Hunk" },
                { "<leader>Gr",         desc = "Reset Hunk" },
                { "<leader>Gb",         desc = "Blame Line" },
                { "<leader>Gd",         desc = "Diff File" },

                -- LSP operations (available when LSP attaches)
                { "<leader>c",          group = "Code" },
                { "<leader>ca",         desc = "Code Actions" },
                { "<leader>cb",         desc = "Run build.sh" },
                { "<leader>cd",         desc = "Line Diagnostics" },
                { "<leader>ci",         desc = "LSP Info" },
                { "<leader>cm",         desc = "Mason Package Manager" },
                { "<leader>cq",         desc = "Diagnostics to Location List" },
                { "<leader>co",         desc = "Open Quickfix List" },
                { "<leader>cc",         desc = "Close Quickfix List" },
                { "<leader>cs",         desc = "Symbols (Trouble)" },
                { "<leader>cl",         desc = "LSP Definitions/References (Trouble)" },

                -- Language-specific features
                -- Rust (rustaceanvim)
                { "<leader>ce",         desc = "Expand Macro" },
                { "<leader>ch",         desc = "Hover Actions" },
                { "<leader>cH",         desc = "Hover Range" },
                { "<leader>cE",         desc = "Explain Error" },
                { "<leader>cR",         desc = "Runnables" },
                { "<leader>cD",         desc = "Debuggables" },

                -- TypeScript/JavaScript
                { "<leader>ts",         group = "TypeScript" },
                { "<leader>tsi",        desc = "Organize Imports" },
                { "<leader>tsr",        desc = "Remove Unused" },
                { "<leader>tsa",        desc = "Add Missing Imports" },
                { "<leader>tsf",        desc = "Fix All Issues" },
                { "<leader>tsR",        desc = "Rename File" },

                -- Package management (package.json)
                { "<leader>n",          group = "NPM/Node" },
                { "<leader>nt",         desc = "Toggle package versions" },
                { "<leader>nu",         desc = "Update package on line" },
                { "<leader>ni",         desc = "Install package on line" },

                -- Refactoring
                { "<leader>r",          group = "Refactor" },
                { "<leader>rn",         desc = "Rename Symbol" },
                { "<leader>re",         desc = "Extract Function",                     mode = "x" },
                { "<leader>rf",         desc = "Extract Function To File",             mode = "x" },
                { "<leader>rv",         desc = "Extract Variable",                     mode = "x" },
                { "<leader>ri",         desc = "Inline Variable" },
                { "<leader>rb",         desc = "Extract Block",                        mode = "x" },
                { "<leader>rbf",        desc = "Extract Block To File",                mode = "x" },

                -- Buffer operations (Doom Emacs style)
                { "<leader>b",          group = "Buffers" },
                { "<leader>bb",         desc = "List buffers (buffer switcher)" },
                { "<leader>b<leader>",  desc = "Toggle to last buffer" },
                { "<leader>bd",         desc = "Delete Buffer" },
                { "<leader>bn",         desc = "Next Buffer" },
                { "<leader>bp",         desc = "Previous Buffer" },
                { "<leader>bD",         desc = "Delete all buffers except current" },

                -- Window management
                { "<leader>w",          group = "Windows" },
                { "<leader>ww",         desc = "Other Window" },
                { "<leader>wd",         desc = "Delete Window" },
                { "<leader>w-",         desc = "Split Below" },
                { "<leader>w|",         desc = "Split Right" },
                { "<leader>|",          desc = "Split window right (quick)" },

                -- Tab management
                { "<leader><tab>",      group = "Tabs" },
                { "<leader><tab>l",     desc = "Last Tab" },
                { "<leader><tab>f",     desc = "First Tab" },
                { "<leader><tab><tab>", desc = "New Tab" },
                { "<leader><tab>]",     desc = "Next Tab" },
                { "<leader><tab>[",     desc = "Previous Tab" },
                { "<leader><tab>d",     desc = "Close Tab" },

                -- Markdown
                { "<leader>m",          group = "Markdown" },
                { "<leader>mp",         desc = "Preview in Browser" },
                { "<leader>mc",         desc = "Close Preview" },

                -- Session/Quit
                { "<leader>q",          group = "Session/Quit" },
                { "<leader>qq",         desc = "Quit All" },
                { "<leader>qs",         desc = "Restore Session" },
                { "<leader>ql",         desc = "Restore Last Session" },
                { "<leader>qd",         desc = "Don't Save Current Session" },

                -- Lazy plugin manager
                { "<leader>l",          desc = "Lazy Plugin Manager" },

                -- Configuration
                { "<leader>R",          desc = "Reload Neovim configuration" },
                { "<leader>ch",         desc = "Check external dependencies" },

                -- Zen mode
                { "<leader>z",          group = "Zen Mode" },
                { "<leader>zz",         desc = "Zen Mode (Ataraxis)" },
                { "<leader>zm",         desc = "Zen Mode (Minimalist)" },
                { "<leader>zf",         desc = "Zen Mode (Focus)" },
                { "<leader>zn",         desc = "Zen Mode (Narrow)",                    mode = "v" },

                -- LSP navigation (non-leader keys)
                { "g",                  group = "Go to" },
                { "gd",                 desc = "Go to Definition" },
                { "gr",                 desc = "Go to References" },
                { "K",                  desc = "Hover Documentation" },

                -- Diagnostics navigation
                { "]",                  group = "Next" },
                { "]d",                 desc = "Next Diagnostic" },
                { "]c",                 desc = "Next Git Hunk" },
                { "[",                  group = "Previous" },
                { "[d",                 desc = "Previous Diagnostic" },
                { "[c",                 desc = "Previous Git Hunk" },

                -- Treesitter text objects
                { "a",                  group = "Around" },
                { "af",                 desc = "Around Function" },
                { "ac",                 desc = "Around Class" },
                { "i",                  group = "Inside" },
                { "if",                 desc = "Inside Function" },
                { "ic",                 desc = "Inside Class" },

                -- Terminal
                { "<C-\\>",             desc = "Toggle Terminal" },

                -- Save shortcuts
                { "<C-s>",              desc = "Save File" },
                { "<D-s>",              desc = "Save File (Cmd+S)" },
                { "<C-S-s>",            desc = "Save without formatting" },
                { "<D-S-s>",            desc = "Save without formatting (Cmd+Shift+S)" },

                -- Comment shortcuts (available when Comment.nvim loads)
                { "gc",                 group = "Comment" },
                { "gcc",                desc = "Toggle Line Comment" },
                { "gb",                 group = "Block Comment" },

                -- Window navigation
                { "<C-h>",              desc = "Go to Left Window" },
                { "<C-j>",              desc = "Go to Lower Window" },
                { "<C-k>",              desc = "Go to Upper Window" },
                { "<C-l>",              desc = "Go to Right Window" },

                -- Treesitter incremental selection
                { "<C-space>",          desc = "Incremental Selection" },
                { "<bs>",               desc = "Decremental Selection" },
            })
        end
    },

    -- Comments
    {
        'numToStr/Comment.nvim',
        keys = { 'gcc', 'gc', 'gb' },
        config = true
    },

    -- Auto-pairs (with blink.cmp integration)
    {
        'windwp/nvim-autopairs',
        event = 'InsertEnter',
        config = function()
            require('nvim-autopairs').setup({
                enable_check_bracket_line = false,
                check_ts = true,
            })

            -- Integration with blink.cmp (handled by blink.cmp's auto_brackets feature)
            -- Note: blink.cmp has built-in auto-brackets, so nvim-autopairs is optional
        end
    },

    -- Surround
    {
        'kylechui/nvim-surround',
        event = 'BufReadPre',
        config = true
    },

    -- Multi-cursor support
    {
        'mg979/vim-visual-multi',
        branch = 'master',
        event = 'VeryLazy', -- Load later to avoid conflicts
        init = function()
            -- Disable features that conflict with LSP
            vim.g.VM_set_statusline = 0 -- disable VM statusline
            vim.g.VM_silent_exit = 1    -- exit silently
            vim.g.VM_show_warnings = 0  -- disable warnings

            -- Enable default mappings but customize conflicts
            vim.g.VM_default_mappings = 1 -- enable default mappings
            vim.g.VM_leader = '\\'        -- use backslash as VM leader (avoid <leader> conflict)

            -- Override specific mappings to avoid conflicts
            vim.g.VM_maps = {
                -- Core selection
                ['Find Under'] = '<C-n>',              -- select word under cursor (Ctrl+n)
                ['Find Subword Under'] = '<C-n>',      -- same as above
                ['Select All'] = '\\A',                -- select all occurrences
                ['Select Cursor Down'] = '<M-C-Down>', -- add cursor down (Alt+Ctrl+Down)
                ['Select Cursor Up'] = '<M-C-Up>',     -- add cursor up (Alt+Ctrl+Up)

                -- Visual mode selection
                ['Visual All'] = '\\A',     -- select all in visual mode
                ['Visual Add'] = '\\a',     -- add cursor at position
                ['Visual Find'] = '\\f',    -- find pattern
                ['Visual Cursors'] = '\\c', -- create cursors from visual

                -- Navigation
                ['Next'] = ']',          -- go to next cursor
                ['Previous'] = '[',      -- go to previous cursor
                ['Skip'] = 'q',          -- skip current and find next
                ['Remove Region'] = 'Q', -- remove current cursor

                -- Selection modification
                ['Increase'] = '+', -- expand selection
                ['Decrease'] = '-', -- shrink selection
                ['Motion ]'] = '}', -- motion to next
                ['Motion ['] = '{', -- motion to previous

                -- Mouse support
                ['Mouse Cursor'] = '<C-LeftMouse>',    -- add cursor with mouse
                ['Mouse Word'] = '<C-RightMouse>',     -- select word with mouse
                ['Mouse Column'] = '<M-C-RightMouse>', -- column selection with mouse

                -- Mode switches
                ['Switch Mode'] = '<Tab>',              -- switch between cursor/extend mode
                ['Toggle Single Region'] = '\\<Space>', -- toggle single region mode

                -- Other operations
                ['Undo'] = 'u',
                ['Redo'] = '<C-r>',
                ['Exit'] = '<Esc>',

                -- Alignment
                ['Align'] = '\\a',       -- align cursors
                ['Align Char'] = '\\<',  -- align by character
                ['Align Regex'] = '\\>', -- align by regex

                -- Text objects in VM
                ['Inner Word'] = 'iw',
                ['A Word'] = 'aw',
                ['Inner Bracket'] = 'i[',
                ['A Bracket'] = 'a[',
            }

            -- Better colors
            vim.g.VM_theme = 'ocean'
            vim.g.VM_highlight_matches = 'underline'

            -- Performance settings
            vim.g.VM_live_editing = 1       -- see changes as you type
            vim.g.VM_case_setting = 'smart' -- smart case matching
            vim.g.VM_use_python = 0         -- don't use python (better performance)

            -- Show hints
            vim.g.VM_show_warnings = 1 -- re-enable warnings for learning
            vim.g.VM_debug = 0
        end,
        config = function()
            -- Additional configuration after plugin loads
            vim.cmd([[
        " Fix highlight groups for better visibility
        highlight VM_Extend guibg=#3b4252 guifg=#d8dee9
        highlight VM_Cursor guibg=#88c0d0 guifg=#2e3440
        highlight VM_Insert guibg=#a3be8c guifg=#2e3440
        highlight VM_Mono guibg=#b48ead guifg=#2e3440
      ]])
        end,
    },

    -- Alpha dashboard (startup screen)
    {
        'goolord/alpha-nvim',
        event = 'VimEnter',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        config = function()
            local alpha = require('alpha')
            local dashboard = require('alpha.themes.dashboard')

            -- Set header with beautiful ASCII art (balanced 60% version)
            dashboard.section.header.val = {
                "                                                     ",
                "         .m.                                   ,_    ",
                "         ' ;M;                                ,;m `  ",
                "           ;M;.           ,      ,           ;SMM;   ",
                "          ;;Mm;         ,;  ____  ;,         ;SMM;  ",
                "         ;;;MM;        ; (.MMMMMM.) ;       ,SSMM;; ",
                "       ,;;;mMp'        l  ';mmmm;/  j       SSSMM;; ",
                "     .;;;;;MM;         .\\,.mmSSSm,,/,      ,SSSMM;;;",
                "    ;;;;;;mMM;        .;MMmSSSSSSSmMm;     ;MSSMM;;;;",
                "   ;;;;;;mMSM;     ,_ ;MMmS;;;;;;mmmM;  -,;MMMMMMm;;;",
                "  ;;;;;;;MMSMM;     \\\"*;M;( ( '') );m;*\"/ ;MMMMMM;;;;",
                " .;;;;;;mMMSMM;      \\(@;! _     _ !;@)/ ;MMMMMMMM;;;;",
                " ;;;;;;;MMSSSM;       ;,;.*o*> <*o*.;m; ;MMMMMMMMM;;;",
                ".;;;;;;;MMSSSMM;     ;Mm;           ;M;,MMMMMMMMMMm;;",
                ";;;;;;;mmMSSSMMMM,   ;Mm;,   '-    ,;M;MMMMMMMSMMMMm;",
                ";;;;;;;MMMSSSSMMMMMM;Mm;;,  ___  ,;SmM;MMMMMMSSMMMM;;",
                ";;'\";;;MMMSSSSMMMMMM;MMmS;;,  \"  ,;SmMM;MMMMMMSSMMMM;;",
                "!   ;;;MMMSSSSSMMMMM;MMMmSS;;._.;;SSmMM;MMMMMMSSMMMM;;",
                "    ;;;;*MSSSSSSMMMP;Mm*\"'q;'   `;p*\"*M;MMMMMSSSSMMM;;",
                "    ';;;  ;SS*SSM*M;M;'     `-.        ;;MMMMSSSSSMM;;",
                "     ;;;. ;P  `q; qMM.                 ';MMMMSSSSSMp' ",
                "     ;;;; ',    ; .mm!     \\.   `.   /  ;MMM' `qSS'   ",
                "     ';;;       ' mmS';     ;     ,  `. ;'M'   `S     ",
                "      `;;.        mS;;`;    ;     ;    ;M,!     '     ",
                "                                                     ",
            }

            -- Custom button function for proper right-alignment
            local function button(sc, txt, keybind)
                local sc_ = sc:gsub("%s", ""):gsub("SPC", "<leader>")

                local opts = {
                    position = "center",
                    shortcut = sc,
                    cursor = 3,
                    width = 50,
                    align_shortcut = "right",
                    hl_shortcut = "Keyword",
                }

                if keybind then
                    opts.keymap = { "n", sc_, keybind, { noremap = true, silent = true, nowait = true } }
                end

                local function on_press()
                    local key = vim.api.nvim_replace_termcodes(keybind or sc_ .. '<Ignore>', true, false, true)
                    vim.api.nvim_feedkeys(key, "t", false)
                end

                return {
                    type = "button",
                    val = txt,
                    on_press = on_press,
                    opts = opts,
                }
            end

            -- Set menu buttons with clean formatting
            dashboard.section.buttons.val = {
                button("f", "  Find File", ":FzfLua files<CR>"),
                button("r", "  Recent File", ":FzfLua oldfiles<CR>"),
                button("g", "  Live Grep", ":FzfLua live_grep<CR>"),
                button("p", "  Projects", ":FzfLua files<CR>"),
                button("k", "  Keymaps", ":FzfLua keymaps<CR>"),
                button("q", "  Quit", ":qa<CR>"),
            }

            -- Set footer
            local function footer()
                local total_plugins = require('lazy').stats().count
                local datetime = os.date(" %Y-%m-%d   %H:%M:%S")
                local version = vim.version()
                local nvim_version_info = "   v" .. version.major .. "." .. version.minor .. "." .. version.patch

                return "⚡ " .. total_plugins .. " plugins" .. nvim_version_info .. datetime
            end

            dashboard.section.footer.val = footer()

            -- Set header highlight to grey
            dashboard.section.header.opts.hl = "Comment"

            -- Disable folding on alpha buffer
            dashboard.config.opts.noautocmd = true

            alpha.setup(dashboard.config)

            -- Auto-open alpha when no files are opened
            vim.api.nvim_create_autocmd('User', {
                pattern = 'LazyVimStarted',
                callback = function()
                    local stats = require('lazy').stats()
                    local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
                    dashboard.section.footer.val = "⚡ " .. stats.count .. " plugins loaded in " .. ms .. "ms"
                    pcall(vim.cmd.AlphaRedraw)
                end,
            })
        end,
    },

    -- True Zen for distraction-free writing
    {
        'Pocco81/true-zen.nvim',
        cmd = { 'TZAtaraxis', 'TZMinimalist', 'TZFocus', 'TZNarrow' },
        keys = {
            { '<leader>zz', '<cmd>TZAtaraxis<cr>',   desc = 'Zen Mode (Ataraxis)' },
            { '<leader>zm', '<cmd>TZMinimalist<cr>', desc = 'Zen Mode (Minimalist)' },
            { '<leader>zf', '<cmd>TZFocus<cr>',      desc = 'Zen Mode (Focus)' },
            { '<leader>zn', '<cmd>TZNarrow<cr>',     desc = 'Zen Mode (Narrow)',    mode = 'v' },
        },
        config = function()
            require('true-zen').setup({
                modes = {
                    ataraxis = {
                        shade = "dark",          -- if `dark` then dim the padding windows, otherwise if it's `light` it'll brighten said windows
                        backdrop = 0.25,         -- percentage by which padding windows should be dimmed/brightened. Must be a number between 0 and 1. Set to 0 to keep the same background color
                        minimum_writing_area = { -- minimum size of main window
                            width = 70,
                            height = 44,
                        },
                        quit_untoggles = true, -- type :q or :qa to quit Ataraxis mode
                        padding = {            -- padding windows
                            left = 52,
                            right = 52,
                            top = 0,
                            bottom = 0,
                        },
                        callbacks = { -- run functions when opening/closing Ataraxis mode
                            open_pre = nil,
                            open_pos = nil,
                            close_pre = nil,
                            close_pos = nil
                        },
                    },
                    minimalist = {
                        ignored_buf_types = { "nofile" }, -- save current options from any window except ones displaying these kinds of buffers
                        options = {                       -- options to be disabled when entering Minimalist mode
                            number = false,
                            relativenumber = false,
                            signcolumn = "no",
                            statusline = "",
                            laststatus = 0,
                        },
                        callbacks = { -- run functions when opening/closing Minimalist mode
                            open_pre = nil,
                            open_pos = nil,
                            close_pre = nil,
                            close_pos = nil
                        },
                    },
                    narrow = {
                        --- change the style of the fold lines. Set it to:
                        --- `informative`: to get nice pre-baked folds
                        --- `invisible`: hide them
                        --- function() end: pass a custom func with your fold lines. See :h foldtext
                        foldtext = function()
                            return vim.fn.getline(vim.v.foldstart) .. " ... " .. vim.fn.getline(vim.v.foldend)
                        end,
                        run_ataraxis = true, -- display narrowed text in a Ataraxis session
                        callbacks = {        -- run functions when opening/closing Narrow mode
                            open_pre = nil,
                            open_pos = nil,
                            close_pre = nil,
                            close_pos = nil
                        },
                    },
                    focus = {
                        callbacks = { -- run functions when opening/closing Focus mode
                            open_pre = nil,
                            open_pos = nil,
                            close_pre = nil,
                            close_pos = nil
                        },
                    }
                },
                integrations = {
                    tmux = false, -- hide tmux status bar in (minimalist, ataraxis)
                    kitty = {     -- increment font size in Kitty. Note: you must set `allow_remote_control socket-only` and `listen_on unix:/tmp/kitty` in your Kitty config
                        enabled = false,
                        font = "+3"
                    },
                    twilight = false, -- enable twilight (ataraxis)
                    lualine = true    -- hide nvim-lualine (ataraxis)
                },
            })
        end,
    },
}
