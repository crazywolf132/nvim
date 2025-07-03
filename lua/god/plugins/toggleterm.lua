return {
    'akinsho/toggleterm.nvim',
    version = "*",
    opts = {
        size = function(term)
            if term.direction == "horizontal" then
                return 15
            elseif term.direction == "vertical" then
                return vim.o.columns * 0.4
            end
        end,
        open_mapping = [[<c-\>]],
        hide_numbers = true,
        shade_filetypes = {},
        shade_terminals = true,
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
                return math.floor(vim.o.columns * 0.9)
            end,
            height = function()
                return math.floor(vim.o.lines * 0.9)
            end,
            winblend = 3,
        },
        winbar = {
            enabled = false,
            name_formatter = function(term)
                return term.name
            end
        },
    },
    config = function(_, opts)
        require('toggleterm').setup(opts)
        
        -- Terminal keymaps
        function _G.set_terminal_keymaps()
            local keymap_opts = {buffer = 0}
            vim.keymap.set('t', 'jk', [[<C-\><C-n>]], keymap_opts)
            vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], keymap_opts)
            vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], keymap_opts)
            vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], keymap_opts)
            vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], keymap_opts)
            vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]], keymap_opts)
        end
        
        vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')
        
        -- Custom terminals
        local Terminal = require('toggleterm.terminal').Terminal
        
        -- Lazygit terminal
        local lazygit = Terminal:new({
            cmd = "lazygit",
            dir = "git_dir",
            direction = "float",
            float_opts = {
                border = "double",
            },
            on_open = function(term)
                vim.cmd("startinsert!")
                vim.keymap.set("n", "q", "<cmd>close<CR>", {buffer = term.bufnr})
            end,
            on_close = function(_)
                vim.cmd("startinsert!")
            end,
        })
        
        function _LAZYGIT_TOGGLE()
            lazygit:toggle()
        end
        
        -- Node terminal
        local node = Terminal:new({ cmd = "node", hidden = true })
        
        function _NODE_TOGGLE()
            node:toggle()
        end
        
        -- Python terminal
        local python = Terminal:new({ cmd = "python3", hidden = true })
        
        function _PYTHON_TOGGLE()
            python:toggle()
        end
        
        -- Keymaps for custom terminals
        vim.keymap.set("n", "<leader>tg", "<cmd>lua _LAZYGIT_TOGGLE()<CR>", { desc = "Toggle lazygit" })
        vim.keymap.set("n", "<leader>tn", "<cmd>lua _NODE_TOGGLE()<CR>", { desc = "Toggle node" })
        vim.keymap.set("n", "<leader>tp", "<cmd>lua _PYTHON_TOGGLE()<CR>", { desc = "Toggle python" })
        
        -- Additional toggleterm keymaps
        vim.keymap.set("n", "<leader>tf", "<cmd>ToggleTerm direction=float<CR>", { desc = "Toggle floating terminal" })
        vim.keymap.set("n", "<leader>th", "<cmd>ToggleTerm size=10 direction=horizontal<CR>", { desc = "Toggle horizontal terminal" })
        vim.keymap.set("n", "<leader>tv", "<cmd>ToggleTerm size=80 direction=vertical<CR>", { desc = "Toggle vertical terminal" })
        vim.keymap.set("n", "<leader>tt", "<cmd>ToggleTerm<CR>", { desc = "Toggle terminal" })
        
        -- Send lines to terminal
        vim.keymap.set("v", "<leader>ts", function()
            require('toggleterm').send_lines_to_terminal("visual_selection", true, { args = vim.v.count })
        end, { desc = "Send selection to terminal" })
    end,
}