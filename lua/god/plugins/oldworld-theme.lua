return {
    'dgox16/oldworld.nvim',
    lazy = false,
    priority = 1000,
    config = function()
        require('oldworld').setup({
            terminal_colors = true, -- enable terminal colors
            variant = 'default', -- options: default, oled, cooler
            styles = {
                comments = { italic = true },
                keywords = { bold = true },
                identifiers = {},
                functions = {},
                variables = {},
                booleans = { bold = true },
            },
            integrations = {
                alpha = true,
                cmp = true,
                flash = false,
                gitsigns = true,
                hop = false,
                indent_blankline = true,
                lazy = true,
                lsp = true,
                markdown = true,
                mason = true,
                navic = true,
                neo_tree = false,
                neogit = false,
                neorg = false,
                noice = false,
                notify = false,
                rainbow_delimiters = true,
                telescope = false, -- we're using fzf-lua
                treesitter = true,
            },
            highlight_overrides = {},
        })
        
        -- Load the colorscheme
        vim.cmd.colorscheme 'oldworld'
        
        -- Ensure the colorscheme persists
        vim.api.nvim_create_autocmd('ColorScheme', {
            pattern = '*',
            callback = function()
                -- Only allow oldworld colorscheme
                if vim.g.colors_name ~= 'oldworld' then
                    vim.schedule(function()
                        vim.cmd.colorscheme 'oldworld'
                    end)
                end
            end,
            desc = 'Enforce oldworld colorscheme'
        })
        
        -- Also set it after all plugins are loaded
        vim.api.nvim_create_autocmd('VimEnter', {
            callback = function()
                vim.schedule(function()
                    if vim.g.colors_name ~= 'oldworld' then
                        vim.cmd.colorscheme 'oldworld'
                    end
                end)
            end,
            desc = 'Ensure oldworld colorscheme on startup'
        })
    end,
}