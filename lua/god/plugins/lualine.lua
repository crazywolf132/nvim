return {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    event = 'VeryLazy',
    opts = {
        options = {
            theme = 'tokyonight',
            component_separators = '',
            section_separators = { left = '', right = '' },
            disabled_filetypes = { 
                statusline = { 'dashboard', 'alpha', 'starter' }
            },
            always_divide_middle = true,
            globalstatus = true,
        },
        sections = {
            lualine_a = {
                {
                    'mode',
                    fmt = function(str)
                        return ' ' .. str:sub(1,1) .. ' '
                    end,
                    separator = { left = '', right = '' },
                },
            },
            lualine_b = {
                { 'branch', icon = '' },
            },
            lualine_c = {
                {
                    'diagnostics',
                    symbols = { error = ' ', warn = ' ', info = ' ', hint = ' ' },
                },
                { 'filetype', icon_only = true, separator = '', padding = { left = 1, right = 0 } },
                { 
                    'filename',
                    path = 1,
                    symbols = { modified = '  ', readonly = '', unnamed = '' },
                    color = { gui = 'bold' }
                },
            },
            lualine_x = {
                {
                    function()
                        local msg = 'No Active Lsp'
                        local buf_ft = vim.api.nvim_buf_get_option(0, 'filetype')
                        local clients = vim.lsp.get_clients()
                        if next(clients) == nil then
                            return msg
                        end
                        for _, client in ipairs(clients) do
                            local filetypes = client.config.filetypes
                            if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
                                return client.name
                            end
                        end
                        return msg
                    end,
                    icon = ' ',
                },
            },
            lualine_y = {
                { 'progress' },
            },
            lualine_z = {
                {
                    'location',
                    separator = { left = '', right = '' },
                }
            },
        },
        inactive_sections = {
            lualine_c = { 'filename' },
            lualine_x = { 'location' },
        },
        extensions = {}
    }
}