return {
    'ibhagwan/fzf-lua',
    event = 'VimEnter',
    dependencies = {
        'nvim-tree/nvim-web-devicons',
    },
    config = function()
        local fzf = require('fzf-lua')
        
        -- Configure fzf-lua
        fzf.setup({
            -- Global options
            winopts = {
                height = 0.85,
                width = 0.80,
                row = 0.35,
                col = 0.50,
                border = 'rounded',
                preview = {
                    default = 'builtin',
                    border = 'border',
                    wrap = 'nowrap',
                    hidden = 'nohidden',
                    vertical = 'down:45%',
                    horizontal = 'right:50%',
                    layout = 'flex',
                    flip_columns = 120,
                    title = true,
                    title_align = 'center',
                    delay = 100,
                },
            },
            keymap = {
                builtin = {
                    ['<C-d>'] = 'preview-page-down',
                    ['<C-u>'] = 'preview-page-up',
                },
            },
            fzf_opts = {
                ['--layout'] = 'reverse',
                ['--info'] = 'inline',
                ['--height'] = '100%',
                ['--preview-window'] = 'right:50%:hidden',
                ['--bind'] = 'ctrl-/:toggle-preview',
            },
            files = {
                prompt = 'Files> ',
                multiprocess = true,
                git_icons = true,
                file_icons = true,
                color_icons = true,
            },
            grep = {
                prompt = 'Rg> ',
                multiprocess = true,
                git_icons = true,
                file_icons = true,
                color_icons = true,
                rg_opts = "--column --line-number --no-heading --color=always --smart-case --max-columns=512",
            },
            lsp = {
                prompt_postfix = '> ',
                cwd_only = false,
                async = true,
                file_icons = true,
                git_icons = false,
                symbols = {
                    symbol_style = 1,
                },
            },
        })

        -- Keymaps for fzf-lua
        local map = vim.keymap.set
        
        -- File pickers
        map('n', '<leader>sf', fzf.files, { desc = '[S]earch [F]iles' })
        map('n', '<leader><leader>', fzf.files, { desc = '[S]earch [F]iles' })
        map('n', '<leader>s.', fzf.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
        map('n', '<leader>fb', fzf.buffers, { desc = '[F]ind [B]uffers' })
        
        -- Grep pickers
        map('n', '<leader>sg', fzf.live_grep, { desc = '[S]earch by [G]rep' })
        map('n', '<leader>sw', fzf.grep_cword, { desc = '[S]earch current [W]ord' })
        map('n', '<leader>sW', fzf.grep_cWORD, { desc = '[S]earch current [W]ORD' })
        
        -- Help and command pickers
        map('n', '<leader>sh', fzf.help_tags, { desc = '[S]earch [H]elp' })
        map('n', '<leader>sk', fzf.keymaps, { desc = '[S]earch [K]eymaps' })
        map('n', '<leader>ss', fzf.builtin, { desc = '[S]earch [S]elect fzf-lua' })
        map('n', '<leader>sc', fzf.commands, { desc = '[S]earch [C]ommands' })
        map('n', '<leader>s:', fzf.command_history, { desc = '[S]earch Command History' })
        
        -- LSP pickers
        map('n', '<leader>sd', fzf.diagnostics_document, { desc = '[S]earch [D]iagnostics' })
        map('n', '<leader>sD', fzf.diagnostics_workspace, { desc = '[S]earch Workspace [D]iagnostics' })
        
        -- Git pickers
        map('n', '<leader>sgf', fzf.git_files, { desc = '[S]earch [G]it [F]iles' })
        map('n', '<leader>sgb', fzf.git_branches, { desc = '[S]earch [G]it [B]ranches' })
        map('n', '<leader>sgc', fzf.git_commits, { desc = '[S]earch [G]it [C]ommits' })
        map('n', '<leader>sgs', fzf.git_status, { desc = '[S]earch [G]it [S]tatus' })
        
        -- Resume last picker
        map('n', '<leader>sr', fzf.resume, { desc = '[S]earch [R]esume' })
        
        -- Project-wide search
        map('n', '<leader>/', fzf.live_grep, { desc = '[/] Search project-wide' })
        
        -- Search in open files
        map('n', '<leader>s/', function()
            fzf.grep({
                prompt = 'Grep Open Files> ',
                cmd = "rg --column --line-number --no-heading --color=always --smart-case",
                file_ignore_patterns = {},
                rg_glob = false,
                actions = fzf.defaults.actions.files,
            })
        end, { desc = '[S]earch [/] in Open Files' })
        
        -- Search Neovim config files
        map('n', '<leader>sn', function()
            fzf.files({ cwd = vim.fn.stdpath 'config' })
        end, { desc = '[S]earch [N]eovim files' })
        
        -- LSP mappings (to be used in LSP attach)
        vim.api.nvim_create_autocmd('LspAttach', {
            group = vim.api.nvim_create_augroup('fzf-lsp-attach', { clear = true }),
            callback = function(event)
                local lmap = function(keys, func, desc, mode)
                    mode = mode or 'n'
                    vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
                end
                
                -- Replace Telescope LSP mappings with fzf-lua
                lmap('grr', fzf.lsp_references, '[G]oto [R]eferences')
                lmap('gri', fzf.lsp_implementations, '[G]oto [I]mplementation')
                -- gd is now handled by smart-goto.lua for better definition navigation
                lmap('gO', fzf.lsp_document_symbols, 'Open Document Symbols')
                lmap('gW', fzf.lsp_workspace_symbols, 'Open Workspace Symbols')
                lmap('grt', fzf.lsp_typedefs, '[G]oto [T]ype Definition')
            end,
        })
    end,
}