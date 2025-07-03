return {
    'folke/flash.nvim',
    event = 'VeryLazy',
    opts = {
        -- Labels to use for jump positions
        labels = "asdfghjklqwertyuiopzxcvbnm",
        search = {
            -- Enable multi-window search
            multi_window = true,
            -- Forward search by default
            forward = true,
            -- Wrap around the buffer
            wrap = true,
            -- Search mode (exact, fuzzy, regex)
            mode = "exact",
        },
        jump = {
            -- Jump position (start, end, range)
            pos = "start",
            -- Automatically jump when there's only one match
            autojump = true,
        },
        label = {
            -- Show labels after the match
            after = true,
            -- Show labels before the match
            before = false,
            -- Style of the label
            style = "overlay",
        },
        highlight = {
            -- Highlight the backdrop
            backdrop = true,
            -- Highlight matches
            matches = true,
        },
        modes = {
            -- Character mode options
            char = {
                enabled = true,
                jump_labels = true,
                multi_line = false,
            },
            -- Search mode options
            search = {
                enabled = true,
            },
        },
    },
    keys = {
        {
            "s",
            mode = { "n", "x", "o" },
            function()
                require("flash").jump()
            end,
            desc = "Flash",
        },
        {
            "S",
            mode = { "n", "x", "o" },
            function()
                require("flash").treesitter()
            end,
            desc = "Flash Treesitter",
        },
        {
            "r",
            mode = "o",
            function()
                require("flash").remote()
            end,
            desc = "Remote Flash",
        },
        {
            "R",
            mode = { "o", "x" },
            function()
                require("flash").treesitter_search()
            end,
            desc = "Treesitter Search",
        },
        {
            "<c-s>",
            mode = { "c" },
            function()
                require("flash").toggle()
            end,
            desc = "Toggle Flash Search",
        },
    },
}