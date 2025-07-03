return {
    'tpope/vim-fugitive',
    event = 'VeryLazy',
    config = function()
        -- Git keybindings
        vim.keymap.set('n', '<leader>gs', vim.cmd.Git, { desc = 'Git status' })
        vim.keymap.set('n', '<leader>gd', '<cmd>Gdiffsplit<CR>', { desc = 'Git diff' })
        vim.keymap.set('n', '<leader>gb', '<cmd>Git blame<CR>', { desc = 'Git blame' })
        vim.keymap.set('n', '<leader>gl', '<cmd>Git log<CR>', { desc = 'Git log' })
        vim.keymap.set('n', '<leader>gc', '<cmd>Git commit<CR>', { desc = 'Git commit' })
        vim.keymap.set('n', '<leader>gp', '<cmd>Git push<CR>', { desc = 'Git push' })
        vim.keymap.set('n', '<leader>gP', '<cmd>Git pull<CR>', { desc = 'Git pull' })
        
        -- Advanced git operations
        vim.keymap.set('n', '<leader>gm', '<cmd>Git mergetool<CR>', { desc = 'Git mergetool' })
        vim.keymap.set('n', '<leader>gr', '<cmd>Gread<CR>', { desc = 'Git checkout file' })
        vim.keymap.set('n', '<leader>gw', '<cmd>Gwrite<CR>', { desc = 'Git add file' })
        
        -- Browse files in git history
        vim.keymap.set('n', '<leader>g0', '<cmd>0Gclog<CR>', { desc = 'Git log for current file' })
    end,
}