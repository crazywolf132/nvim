-- plugins/devtools.lua
-- Dev-related plugins (treesitter, git, terminal, etc.)

return {
  -- Treesitter for syntax highlighting
  { 
    'nvim-treesitter/nvim-treesitter', 
    build = ':TSUpdate', 
    event = 'BufReadPre', 
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = { 
          'rust', 'go', 'lua', 'vim', 'vimdoc', 
          'typescript', 'tsx', 'javascript',
          'html', 'css', 'scss',
          'markdown', 'markdown_inline', 
          'json', 'yaml', 'toml', 
          'bash', 'dockerfile', 'gitignore',
          'sql', 'regex', 'make'
        },
        highlight = { enable = true },
        indent = { enable = true },
        incremental_selection = { 
          enable = true,
          keymaps = {
            init_selection = '<C-space>',
            node_incremental = '<C-space>',
            scope_incremental = false,
            node_decremental = '<bs>',
          },
        },
        textobjects = { enable = true },
      }
    end
  },
  
  -- Treesitter textobjects
  { 
    'nvim-treesitter/nvim-treesitter-textobjects', 
    dependencies = { 'nvim-treesitter' },
    config = function()
      require('nvim-treesitter.configs').setup {
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ['af'] = '@function.outer',
              ['if'] = '@function.inner',
              ['ac'] = '@class.outer',
              ['ic'] = '@class.inner',
            },
          },
          move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
              [']m'] = '@function.outer',
              [']]'] = '@class.outer',
            },
            goto_next_end = {
              [']M'] = '@function.outer',
              [']['] = '@class.outer',
            },
            goto_previous_start = {
              ['[m'] = '@function.outer',
              ['[['] = '@class.outer',
            },
            goto_previous_end = {
              ['[M'] = '@function.outer',
              ['[]'] = '@class.outer',
            },
          },
        },
      }
    end
  },
  
  -- Treesitter context (shows current function/class at top)
  {
    'nvim-treesitter/nvim-treesitter-context',
    dependencies = { 'nvim-treesitter' },
    event = 'BufReadPre',
    config = function()
      require('treesitter-context').setup {
        enable = true,
        max_lines = 3,
        trim_scope = 'outer',
        patterns = {
          default = {
            'class',
            'function',
            'method',
            'for',
            'while',
            'if',
            'switch',
            'case',
          },
        },
      }
    end
  },
  
  -- Indent guides
  { 
    'lukas-reineke/indent-blankline.nvim', 
    event = 'BufReadPre', 
    main = 'ibl',
    config = function()
      require('ibl').setup {
        indent = { char = '│' },
        scope = { enabled = false },
      }
    end 
  },
  
  -- FZF-Lua fuzzy finder (faster alternative to Telescope)
  {
    'ibhagwan/fzf-lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('fzf-lua').setup({
        'default-title',
        winopts = {
          height = 0.85,
          width = 0.90,
          row = 0.35,
          col = 0.50,
          border = { '┏', '━', '┓', '┃', '┛', '━', '┗', '┃' },
          preview = {
            border = 'border',
            wrap = 'nowrap',
            hidden = 'nohidden',
            vertical = 'down:45%',
            horizontal = 'right:50%',
            layout = 'flex',
            flip_columns = 120,
          },
        },
        keymap = {
          builtin = {
            ["<F1>"] = "toggle-help",
            ["<F2>"] = "toggle-fullscreen",
            ["<F3>"] = "toggle-preview-wrap",
            ["<F4>"] = "toggle-preview",
            ["<F5>"] = "toggle-preview-ccw",
            ["<F6>"] = "toggle-preview-cw",
            ["<S-down>"] = "preview-page-down",
            ["<S-up>"] = "preview-page-up",
            ["<S-left>"] = "preview-page-reset",
          },
          fzf = {
            ["ctrl-z"] = "abort",
            ["ctrl-u"] = "unix-line-discard",
            ["ctrl-f"] = "half-page-down",
            ["ctrl-b"] = "half-page-up",
            ["ctrl-a"] = "beginning-of-line",
            ["ctrl-e"] = "end-of-line",
            ["alt-a"] = "toggle-all",
            ["f3"] = "toggle-preview-wrap",
            ["f4"] = "toggle-preview",
            ["shift-down"] = "preview-page-down",
            ["shift-up"] = "preview-page-up",
          },
        },
        previewers = {
          cat = {
            cmd = "cat",
            args = "--number",
          },
          bat = {
            cmd = "bat",
            args = "--style=numbers,changes --color always",
            theme = 'Coldark-Dark', -- bat preview theme (fallback to cat if bat not available)
          },
          head = {
            cmd = "head",
            args = nil,
          },
          git_diff = {
            cmd_deleted = "git show HEAD:./{file}",
            cmd_modified = "git diff HEAD ./{file}",
            cmd_untracked = "git diff --no-index /dev/null ./{file}",
          },
        },
        files = {
          prompt = 'Files❯ ',
          multiprocess = true,
          git_icons = true,
          file_icons = true,
          color_icons = true,
          find_opts = [[-type f -not -path '*/\.git/*' -printf '%P\n']],
          rg_opts = "--color=never --files --hidden --follow -g '!.git'",
          fd_opts = "--color=never --type f --hidden --follow --exclude .git",
        },
        git = {
          files = {
            prompt = 'GitFiles❯ ',
            cmd = 'git ls-files --exclude-standard',
            multiprocess = true,
            git_icons = true,
            file_icons = true,
            color_icons = true,
          },
          status = {
            prompt = 'GitStatus❯ ',
            preview_pager = "delta --width=$FZF_PREVIEW_COLUMNS",
          },
          commits = {
            prompt = 'Commits❯ ',
            preview_pager = "delta --width=$FZF_PREVIEW_COLUMNS",
          },
          bcommits = {
            prompt = 'BCommits❯ ',
            preview_pager = "delta --width=$FZF_PREVIEW_COLUMNS",
          },
          branches = {
            prompt = 'Branches❯ ',
          },
        },
        grep = {
          prompt = 'Rg❯ ',
          input_prompt = 'Grep For❯ ',
          multiprocess = true,
          git_icons = true,
          file_icons = true,
          color_icons = true,
          rg_opts = "--column --line-number --no-heading --color=always --smart-case --max-columns=4096 -e",
          grep_opts = "--binary-files=without-match --line-number --recursive --color=auto --perl-regexp -e",
        },
        args = {
          prompt = 'Args❯ ',
          files_only = true,
        },
        oldfiles = {
          prompt = 'History❯ ',
          cwd_only = false,
        },
        buffers = {
          prompt = 'Buffers❯ ',
          file_icons = true,
          color_icons = true,
          sort_lastused = true,
        },
        tabs = {
          prompt = 'Tabs❯ ',
          tab_title = "Tab",
          tab_marker = "<<",
          file_icons = true,
          color_icons = true,
        },
        lines = {
          previewer = "builtin",
          prompt = 'Lines❯ ',
          show_filename = true,
          file_icons = true,
          color_icons = true,
        },
        blines = {
          previewer = "builtin",
          prompt = 'BLines❯ ',
          show_filename = true,
          file_icons = true,
          color_icons = true,
        },
        tags = {
          prompt = 'Tags❯ ',
          ctags_file = "tags",
          multiprocess = true,
        },
        btags = {
          prompt = 'BTags❯ ',
          ctags_file = "tags",
          multiprocess = true,
        },
        colorschemes = {
          prompt = 'Colorschemes❯ ',
          live_preview = true,
          actions = { ["default"] = { fn = require('fzf-lua.actions').colorscheme, exec_silent = true } },
          winopts = { height = 0.55, width = 0.30, },
          post_reset_cb = function()
            require('fzf-lua.utils').reset_info()
          end,
        },
        helptags = {
          prompt = 'Help❯ ',
          actions = {
            ["default"] = require('fzf-lua.actions').help,
            ["ctrl-s"] = require('fzf-lua.actions').help,
            ["ctrl-v"] = require('fzf-lua.actions').help_vert,
            ["ctrl-t"] = require('fzf-lua.actions').help_tab,
          }
        },
        manpages = {
          prompt = 'ManPages❯ ',
          actions = {
            ["default"] = require('fzf-lua.actions').man,
            ["ctrl-s"] = require('fzf-lua.actions').man,
            ["ctrl-v"] = require('fzf-lua.actions').man_vert,
            ["ctrl-t"] = require('fzf-lua.actions').man_tab,
          }
        },
        lsp = {
          prompt_postfix = '❯ ',
          cwd_only = false,
          async_or_timeout = 5000,
        },
        diagnostics = {
          prompt = 'Diagnostics❯ ',
          cwd_only = false,
        },
      })
    end,
  },
  
  -- Git integration
  { 
    'tpope/vim-fugitive', 
    cmd = { 'Git', 'Gdiffsplit', 'Gblame', 'Gpush', 'Gpull' } 
  },
  
  -- Lazygit integration
  {
    'kdheepak/lazygit.nvim',
    cmd = 'LazyGit',
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    keys = {
      { '<leader>gl', '<cmd>LazyGit<cr>', desc = 'LazyGit' },
    },
  },
  
  { 
    'lewis6991/gitsigns.nvim', 
    event = 'BufReadPre', 
    config = function()
      require('gitsigns').setup {
        current_line_blame = true,
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          local function map(mode, l, r, desc)
            vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
          end
          map('n', ']c', gs.next_hunk, 'Next Git Hunk')
          map('n', '[c', gs.prev_hunk, 'Prev Git Hunk')
          map('n', '<leader>Gs', gs.stage_hunk, 'Stage Hunk')
          map('n', '<leader>Gu', gs.undo_stage_hunk, 'Undo Stage Hunk')
          map('n', '<leader>Gr', gs.reset_hunk, 'Reset Hunk')
          map('n', '<leader>Gb', gs.blame_line, 'Blame Line')
          map('n', '<leader>Gd', gs.diffthis, 'Diff This File')
        end
      }
    end
  },
  
  { 
    'sindrets/diffview.nvim', 
    cmd = { 'DiffviewOpen', 'DiffviewFileHistory' }, 
    dependencies = 'nvim-lua/plenary.nvim' 
  },
  
  -- Terminal
  { 
    'akinsho/toggleterm.nvim', 
    keys = { [[<C-\>]] }, 
    config = function()
      require('toggleterm').setup{
        open_mapping = [[<C-\>]],
        direction = 'float',  -- default to float
        float_opts = { border = 'curved' },
        size = function(term)
          if term.direction == "horizontal" then
            return 15
          elseif term.direction == "vertical" then
            return vim.o.columns * 0.4
          end
        end,
      }
    end
  },
  
  -- Markdown preview
  { 
    'iamcco/markdown-preview.nvim', 
    ft = 'markdown', 
    build = 'cd app && npm install', 
    config = function()
      vim.g.mkdp_auto_close = 1  -- auto-close preview on buffer close
      vim.g.mkdp_open_to_the_world = 0
      vim.g.mkdp_browser = ''       -- use default browser
      vim.g.mkdp_theme = 'dark'
    end
  },
  
  -- Alternative: Glow markdown preview (terminal-based)
  -- Renders markdown in a floating window using the glow CLI
  -- Install glow first: brew install glow
  {
    'ellisonleao/glow.nvim',
    cmd = 'Glow',
    config = function()
      require('glow').setup({
        border = 'rounded',
        width = 120,
        height = 100,
        width_ratio = 0.8,
        height_ratio = 0.8,
      })
    end
  },
  
  -- EditorConfig support
  -- Automatically applies project-specific settings from .editorconfig files
  {
    'editorconfig/editorconfig-vim',
    event = 'BufReadPre',
  },
  
  -- React/JSX/TSX Auto-tag closing and renaming - PERFORMANCE OPTIMIZED
  {
    'windwp/nvim-ts-autotag',
    dependencies = 'nvim-treesitter/nvim-treesitter',
    ft = { 'html', 'javascript', 'typescript', 'javascriptreact', 'typescriptreact', 'vue', 'svelte' },
    config = function()
      require('nvim-ts-autotag').setup({
        opts = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = false
        },
        per_filetype = {
          ["html"] = { enable_close = false }
        }
      })
    end,
  },
  
  -- Package info for package.json (like crates.nvim for npm) - PERFORMANCE OPTIMIZED
  {
    'vuki656/package-info.nvim',
    dependencies = 'MunifTanjim/nui.nvim',
    ft = "json",
    cond = function()
      return vim.fn.expand('%:t') == 'package.json'
    end,
    config = function()
      require('package-info').setup({
        colors = {
          up_to_date = "#3C4048",
          outdated = "#d19a66",
        },
        icons = {
          enable = true,
          style = {
            up_to_date = "|  ",
            outdated = "|  ",
          },
        },
        autostart = false, -- Don't autostart for performance
        hide_up_to_date = true, -- Hide up-to-date packages to reduce clutter
        hide_unstable_versions = true,
        package_manager = 'npm'
      })
    end,
    keys = {
      { "<leader>nt", function() require('package-info').toggle() end, desc = "Toggle package versions" },
      { "<leader>nu", function() require('package-info').update() end, desc = "Update package on line" },
      { "<leader>ni", function() require('package-info').install() end, desc = "Install package on line" },
    },
  },
  
  -- TypeScript Tools (enhanced TS support) - PERFORMANCE OPTIMIZED
  {
    'pmizio/typescript-tools.nvim',
    dependencies = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' },
    ft = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
    cond = function()
      -- Only load if we're in a JS/TS project
      return vim.fn.glob("package.json") ~= "" or 
             vim.fn.glob("tsconfig.json") ~= "" or 
             vim.fn.glob("jsconfig.json") ~= ""
    end,
    config = function()
      -- Disable basic ts_ls to prevent conflicts
      local clients = vim.lsp.get_active_clients()
      for _, client in ipairs(clients) do
        if client.name == "ts_ls" then
          client.stop()
        end
      end
      
      require('typescript-tools').setup({
        on_attach = function(client, bufnr)
          -- Disable formatting (let prettier handle it)
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false
          
          -- Optimize by disabling some heavy features for better performance
          client.server_capabilities.semanticTokensProvider = nil
          
          -- Essential TypeScript keymaps only
          vim.keymap.set('n', '<leader>tsi', '<cmd>TSToolsOrganizeImports<cr>', { buffer = bufnr, desc = 'Organize Imports' })
          vim.keymap.set('n', '<leader>tsr', '<cmd>TSToolsRemoveUnused<cr>', { buffer = bufnr, desc = 'Remove Unused' })
          vim.keymap.set('n', '<leader>tsa', '<cmd>TSToolsAddMissingImports<cr>', { buffer = bufnr, desc = 'Add Missing Imports' })
          vim.keymap.set('n', '<leader>tsf', '<cmd>TSToolsFixAll<cr>', { buffer = bufnr, desc = 'Fix All Issues' })
          vim.keymap.set('n', '<leader>tsR', '<cmd>TSToolsRenameFile<cr>', { buffer = bufnr, desc = 'Rename File' })
        end,
        settings = {
          separate_diagnostic_server = true,
          publish_diagnostic_on = "insert_leave",
          tsserver_max_memory = 4096, -- Limit memory usage
          tsserver_format_options = {},
          tsserver_file_preferences = {
            -- Minimal inlay hints for performance
            includeInlayParameterNameHints = "literals",
            includeInlayParameterNameHintsWhenArgumentMatchesName = false,
            includeInlayFunctionParameterTypeHints = false,
            includeInlayVariableTypeHints = false,
            includeInlayPropertyDeclarationTypeHints = false,
            includeInlayFunctionLikeReturnTypeHints = false,
            includeInlayEnumMemberValueHints = false,
          },
          complete_function_calls = false,
          include_completions_with_insert_text = true,
          code_lens = "off",
          disable_member_code_lens = true,
          jsx_close_tag = {
            enable = false, -- Let nvim-ts-autotag handle this
            filetypes = { "javascriptreact", "typescriptreact" },
          }
        },
      })
    end,
  },
  
  -- Oil.nvim - Better file explorer (replaces netrw)
  {
    'stevearc/oil.nvim',
    dependencies = { "nvim-tree/nvim-web-devicons" },
    lazy = false,
    config = function()
      require("oil").setup({
        default_file_explorer = true,
        columns = {
          "icon",
          "permissions",
          "size",
          "mtime",
        },
        buf_options = {
          buflisted = false,
          bufhidden = "hide",
        },
        win_options = {
          wrap = false,
          signcolumn = "no",
          cursorcolumn = false,
          foldcolumn = "0",
          spell = false,
          list = false,
          conceallevel = 3,
          concealcursor = "nvic",
        },
        delete_to_trash = true,
        skip_confirm_for_simple_edits = false,
        view_options = {
          show_hidden = true,
          is_hidden_file = function(name, bufnr)
            return vim.startswith(name, ".")
          end,
          is_always_hidden = function(name, bufnr)
            return false
          end,
        },
        keymaps = {
          ["g?"] = "actions.show_help",
          ["<CR>"] = "actions.select",
          ["<C-v>"] = "actions.select_vsplit",
          ["<C-h>"] = "actions.select_split",
          ["<C-t>"] = "actions.select_tab",
          ["<C-p>"] = "actions.preview",
          ["<C-c>"] = "actions.close",
          ["<C-l>"] = "actions.refresh",
          ["-"] = "actions.parent",
          ["_"] = "actions.open_cwd",
          ["`"] = "actions.cd",
          ["~"] = "actions.tcd",
          ["gs"] = "actions.change_sort",
          ["gx"] = "actions.open_external",
          ["g."] = "actions.toggle_hidden",
          ["g\\"] = "actions.toggle_trash",
        },
        use_default_keymaps = true,
      })
      
      -- Open parent directory in current window
      vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
      
      -- Open oil in a floating window
      vim.keymap.set("n", "<leader>e", function()
        require("oil").open_float()
      end, { desc = "Open file explorer (floating)" })
    end,
  },
  
  -- Aerial.nvim - Code structure and symbol outline
  {
    'stevearc/aerial.nvim',
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons"
    },
    keys = {
      { "<leader>a", "<cmd>AerialToggle!<cr>", desc = "Aerial (Symbols)" },
      { "<leader>A", "<cmd>AerialNavToggle<cr>", desc = "Aerial Navigation" },
    },
    config = function()
      require("aerial").setup({
        -- optionally use on_attach to set keymaps when aerial has attached to a buffer
        on_attach = function(bufnr)
          -- Jump forwards/backwards with '{' and '}'
          vim.keymap.set("n", "{", "<cmd>AerialPrev<cr>", { buffer = bufnr })
          vim.keymap.set("n", "}", "<cmd>AerialNext<cr>", { buffer = bufnr })
        end,
        layout = {
          max_width = { 40, 0.2 },
          width = nil,
          min_width = 10,
          win_opts = {},
          default_direction = "prefer_right",
          placement = "window",
        },
        attach_mode = "window",
        backends = { "lsp", "treesitter", "markdown", "man" },
        show_guides = true,
        filter_kind = {
          "Class",
          "Constructor",
          "Enum",
          "Function",
          "Interface",
          "Module",
          "Method",
          "Struct",
          "Type",
          "Variable",
        },
        -- Disable on files with more than 5000 lines
        disable_max_lines = 5000,
        -- Disable on files with more than 2MB
        disable_max_size = 2000000, -- Default 2MB
        -- Automatically open aerial when entering supported buffers
        open_automatic = false,
      })
    end,
  },

  -- Todo Comments - Highlight and search TODOs
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "BufReadPost",
    keys = {
      { "<leader>st", "<cmd>TodoFzfLua<cr>", desc = "Search TODOs" },
      { "<leader>sT", "<cmd>TodoFzfLua keywords=TODO,FIX,FIXME<cr>", desc = "Search TODO/FIX/FIXME" },
      { "]t", function() require("todo-comments").jump_next() end, desc = "Next todo comment" },
      { "[t", function() require("todo-comments").jump_prev() end, desc = "Previous todo comment" },
    },
    config = function()
      require("todo-comments").setup({
        signs = true, -- show icons in the signs column
        sign_priority = 8, -- sign priority
        keywords = {
          FIX = {
            icon = " ", -- icon used for the sign, and in search results
            color = "error", -- can be a hex color, or a named color (see below)
            alt = { "FIXME", "BUG", "FIXIT", "ISSUE" }, -- a set of other keywords that all map to this FIX keywords
          },
          TODO = { icon = " ", color = "info" },
          HACK = { icon = " ", color = "warning" },
          WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
          PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
          NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
          TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
        },
        gui_style = {
          fg = "NONE", -- The gui style to use for the fg highlight group.
          bg = "BOLD", -- The gui style to use for the bg highlight group.
        },
        merge_keywords = true, -- when true, custom keywords will be merged with the defaults
        highlight = {
          multiline = true, -- enable multine todo comments
          multiline_pattern = "^.", -- lua pattern to match the next multiline from the start of the matched keyword
          multiline_context = 10, -- extra lines of context to show around the todo comment
          before = "", -- "fg" or "bg" or empty
          keyword = "wide", -- "fg", "bg", "wide", "wide_bg", "wide_fg" or empty. (wide and wide_bg is the same as bg, but will also highlight surrounding characters, wide_fg acts accordingly but with fg)
          after = "fg", -- "fg" or "bg" or empty
          pattern = [[.*<(KEYWORDS)\s*:]], -- pattern or table of patterns, used for highlighting (vim regex)
          comments_only = true, -- uses treesitter to match keywords in comments only
          max_line_len = 400, -- ignore lines longer than this
          exclude = {}, -- list of file types to exclude highlighting
        },
        colors = {
          error = { "DiagnosticError", "ErrorMsg", "#DC2626" },
          warning = { "DiagnosticWarn", "WarningMsg", "#FBBF24" },
          info = { "DiagnosticInfo", "#2563EB" },
          hint = { "DiagnosticHint", "#10B981" },
          default = { "Identifier", "#7C3AED" },
          test = { "Identifier", "#FF006E" }
        },
        search = {
          command = "rg",
          args = {
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
          },
          pattern = [[\b(KEYWORDS):]], -- ripgrep regex
        },
      })
    end,
  },

  -- Session management
  {
    "folke/persistence.nvim",
    event = "VimEnter", -- Load after startup, not on every buffer read
    keys = {
      { "<leader>qs", function() require("persistence").load() end, desc = "Restore Session" },
      { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session" },
      { "<leader>qd", function() require("persistence").stop() end, desc = "Don't Save Current Session" },
    },
    config = function()
      require("persistence").setup({
        dir = vim.fn.stdpath("state") .. "/sessions/", -- directory where session files are saved
        options = { "buffers", "curdir", "tabpages", "winsize" }, -- sessionoptions used for saving
        pre_save = nil, -- a function to call before saving the session
        post_save = nil, -- a function to call after saving the session
      })
    end,
  },

  -- Refactoring tools
  {
    "ThePrimeagen/refactoring.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    keys = {
      { "<leader>re", function() require('refactoring').refactor('Extract Function') end, mode = "x", desc = "Extract Function" },
      { "<leader>rf", function() require('refactoring').refactor('Extract Function To File') end, mode = "x", desc = "Extract Function To File" },
      { "<leader>rv", function() require('refactoring').refactor('Extract Variable') end, mode = "x", desc = "Extract Variable" },
      { "<leader>ri", function() require('refactoring').refactor('Inline Variable') end, mode = { "n", "x" }, desc = "Inline Variable" },
      { "<leader>rb", function() require('refactoring').refactor('Extract Block') end, mode = "x", desc = "Extract Block" },
      { "<leader>rbf", function() require('refactoring').refactor('Extract Block To File') end, mode = "x", desc = "Extract Block To File" },
    },
    config = function()
      require("refactoring").setup({
        prompt_func_return_type = {
          go = false,
          java = false,
          cpp = false,
          c = false,
          h = false,
          hpp = false,
          cxx = false,
        },
        prompt_func_param_type = {
          go = false,
          java = false,
          cpp = false,
          c = false,
          h = false,
          hpp = false,
          cxx = false,
        },
        printf_statements = {},
        print_var_statements = {},
        show_success_message = false, -- shows a message with information about the refactor on success
      })
    end,
  },

  -- Harpoon v2 for quick file navigation
  {
    'ThePrimeagen/harpoon',
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local harpoon = require("harpoon")
      harpoon:setup({
        settings = {
          save_on_toggle = true,
          sync_on_ui_close = true,
          key = function()
            return vim.loop.cwd()
          end,
        },
      })
      
      -- Basic navigation
      vim.keymap.set("n", "<leader>ha", function() harpoon:list():add() end, { desc = "Add file to Harpoon" })
      vim.keymap.set("n", "<leader>hh", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Toggle Harpoon menu" })
      
      -- Direct navigation with number keys
      vim.keymap.set("n", "<leader>1", function() harpoon:list():select(1) end, { desc = "Harpoon file 1" })
      vim.keymap.set("n", "<leader>2", function() harpoon:list():select(2) end, { desc = "Harpoon file 2" })
      vim.keymap.set("n", "<leader>3", function() harpoon:list():select(3) end, { desc = "Harpoon file 3" })
      vim.keymap.set("n", "<leader>4", function() harpoon:list():select(4) end, { desc = "Harpoon file 4" })
      vim.keymap.set("n", "<leader>5", function() harpoon:list():select(5) end, { desc = "Harpoon file 5" })
      
      -- Quick navigation with Alt + number (more ergonomic)
      vim.keymap.set("n", "<M-1>", function() harpoon:list():select(1) end, { desc = "Quick: Harpoon 1" })
      vim.keymap.set("n", "<M-2>", function() harpoon:list():select(2) end, { desc = "Quick: Harpoon 2" })
      vim.keymap.set("n", "<M-3>", function() harpoon:list():select(3) end, { desc = "Quick: Harpoon 3" })
      vim.keymap.set("n", "<M-4>", function() harpoon:list():select(4) end, { desc = "Quick: Harpoon 4" })
      vim.keymap.set("n", "<M-5>", function() harpoon:list():select(5) end, { desc = "Quick: Harpoon 5" })
      
      -- Navigate between harpoon files
      vim.keymap.set("n", "<leader>hp", function() harpoon:list():prev() end, { desc = "Previous Harpoon file" })
      vim.keymap.set("n", "<leader>hn", function() harpoon:list():next() end, { desc = "Next Harpoon file" })
      
      -- Quick cycle with Tab
      vim.keymap.set("n", "<leader><Tab>", function() harpoon:list():next() end, { desc = "Cycle Harpoon files" })
      
      -- Remove files
      vim.keymap.set("n", "<leader>hr", function() harpoon:list():remove() end, { desc = "Remove from Harpoon" })
      vim.keymap.set("n", "<leader>hc", function() harpoon:list():clear() end, { desc = "Clear Harpoon list" })
    end,
  },
}
