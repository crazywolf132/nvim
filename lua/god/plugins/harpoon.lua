return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
        local harpoon = require("harpoon")
        
        -- REQUIRED
        harpoon:setup({
            settings = {
                save_on_toggle = true,
                sync_on_ui_close = true,
                key = function()
                    return vim.loop.cwd()
                end,
            },
        })
        
        -- Basic keymaps
        vim.keymap.set("n", "<leader>ha", function() harpoon:list():add() end, { desc = "Harpoon add file" })
        vim.keymap.set("n", "<leader>hh", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Harpoon menu" })
        
        -- Navigate to specific files
        vim.keymap.set("n", "<leader>h1", function() harpoon:list():select(1) end, { desc = "Harpoon file 1" })
        vim.keymap.set("n", "<leader>h2", function() harpoon:list():select(2) end, { desc = "Harpoon file 2" })
        vim.keymap.set("n", "<leader>h3", function() harpoon:list():select(3) end, { desc = "Harpoon file 3" })
        vim.keymap.set("n", "<leader>h4", function() harpoon:list():select(4) end, { desc = "Harpoon file 4" })
        
        -- Quick navigation with Alt/Option key
        vim.keymap.set("n", "<M-1>", function() harpoon:list():select(1) end, { desc = "Harpoon file 1" })
        vim.keymap.set("n", "<M-2>", function() harpoon:list():select(2) end, { desc = "Harpoon file 2" })
        vim.keymap.set("n", "<M-3>", function() harpoon:list():select(3) end, { desc = "Harpoon file 3" })
        vim.keymap.set("n", "<M-4>", function() harpoon:list():select(4) end, { desc = "Harpoon file 4" })
        
        -- Toggle previous & next buffers stored within Harpoon list
        vim.keymap.set("n", "<leader>hp", function() harpoon:list():prev() end, { desc = "Harpoon previous" })
        vim.keymap.set("n", "<leader>hn", function() harpoon:list():next() end, { desc = "Harpoon next" })
        
        -- Quick toggle between last two files
        vim.keymap.set("n", "<leader>ht", function() 
            harpoon:list():select(vim.fn.line('.') == 1 and 2 or 1) 
        end, { desc = "Harpoon toggle last two" })
    end,
}