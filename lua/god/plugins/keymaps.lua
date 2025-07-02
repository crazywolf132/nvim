return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
        local wk = require("which-key")
        
        -- Set up which-key
        wk.setup()
        
        -- Define keymaps
        local mappings = {
            -- Quick quit
            ["<leader>qq"] = { "<cmd>qa<cr>", "Quit all" },
            ["<leader>qQ"] = { "<cmd>qa!<cr>", "Force quit all" },
            
            -- Buffer management
            ["<leader>bd"] = { "<cmd>bdelete<cr>", "Delete buffer" },
            ["<leader>bD"] = { "<cmd>bdelete!<cr>", "Force delete buffer" },
            ["<leader>bn"] = { "<cmd>bnext<cr>", "Next buffer" },
            ["<leader>bp"] = { "<cmd>bprevious<cr>", "Previous buffer" },
            ["<leader>ba"] = { "<cmd>ball<cr>", "Open all buffers" },
            ["<leader>bc"] = { "<cmd>bdelete<cr><cmd>bnext<cr>", "Close buffer and go to next" },
            ["<leader>bC"] = { "<cmd>%bd|e#|bd#<cr>", "Close all buffers except current" },
            ["<leader>`"] = { "<cmd>b#<cr>", "Toggle between buffers" },
            
            -- Additional useful mappings
            ["<leader>w"] = { "<cmd>w<cr>", "Save file" },
            ["<leader>W"] = { "<cmd>wa<cr>", "Save all files" },
            
            -- Window management
            ["<leader>wd"] = { "<C-W>c", "Delete window" },
            ["<leader>w-"] = { "<C-W>s", "Split window below" },
            ["<leader>w|"] = { "<C-W>v", "Split window right" },
            ["<leader>ww"] = { "<C-W>w", "Switch windows" },
            ["<leader>wh"] = { "<C-W>h", "Go to left window" },
            ["<leader>wj"] = { "<C-W>j", "Go to lower window" },
            ["<leader>wk"] = { "<C-W>k", "Go to upper window" },
            ["<leader>wl"] = { "<C-W>l", "Go to right window" },
            
            -- Tab management
            ["<leader>tn"] = { "<cmd>tabnew<cr>", "New tab" },
            ["<leader>tc"] = { "<cmd>tabclose<cr>", "Close tab" },
            ["<leader>to"] = { "<cmd>tabonly<cr>", "Close other tabs" },
            ["<leader>th"] = { "<cmd>tabprevious<cr>", "Previous tab" },
            ["<leader>tl"] = { "<cmd>tabnext<cr>", "Next tab" },
            
            -- File explorer
            ["<leader>e"] = { "<cmd>Oil<cr>", "Open file explorer (Oil)" },
            ["<leader>E"] = { "<cmd>Oil .<cr>", "Open Oil in current directory" },
            ["-"] = { "<cmd>Oil<cr>", "Open parent directory" },
            
            -- Rust specific (only active in rust files)
            ["<leader>rc"] = { 
                function()
                    if vim.bo.filetype == "rust" then
                        vim.cmd("RustLsp flyCheck")
                    end
                end, 
                "Run cargo check (Rust)" 
            },
            ["<leader>rf"] = { 
                function()
                    if vim.bo.filetype == "rust" then
                        vim.lsp.buf.format({ async = false })
                        vim.notify("Formatted Rust file", vim.log.levels.INFO)
                    end
                end, 
                "Format Rust file" 
            },
        }
        
        -- Register the mappings
        wk.register(mappings)
        
        -- Register group names
        wk.register({
            ["<leader>b"] = { name = "+buffer" },
            ["<leader>q"] = { name = "+quit" },
            ["<leader>w"] = { name = "+window/save" },
            ["<leader>t"] = { name = "+tab" },
            ["<leader>r"] = { name = "+rust/recent" },
        })
    end,
}