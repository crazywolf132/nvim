return {
    {
        'akinsho/toggleterm.nvim',
        version = "*",
        config = function()
            require("toggleterm").setup({
                open_mapping = [[<c-\>]],
                direction = 'float',
                float_opts = {
                    border = 'curved',
                    winblend = 3,
                },
                size = function(term)
                    if term.direction == "horizontal" then
                        return 15
                    elseif term.direction == "vertical" then
                        return vim.o.columns * 0.4
                    end
                end,
            })
        end,
        keys = {
            { "<C-\\>", desc = "Toggle terminal" },
        },
    }
}