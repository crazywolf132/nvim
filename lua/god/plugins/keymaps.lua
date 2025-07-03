return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
        local wk = require("which-key")
        
        -- Set up which-key
        wk.setup()
        
        -- Define keymaps using new spec format
        wk.add({
            -- Quick quit
            { "<leader>qq", "<cmd>qa<cr>", desc = "Quit all" },
            { "<leader>qQ", "<cmd>qa!<cr>", desc = "Force quit all" },
            
            -- Buffer management
            { "<leader>bd", "<cmd>bdelete<cr>", desc = "Delete buffer" },
            { "<leader>bD", "<cmd>bdelete!<cr>", desc = "Force delete buffer" },
            { "<leader>bn", "<cmd>bnext<cr>", desc = "Next buffer" },
            { "<leader>bp", "<cmd>bprevious<cr>", desc = "Previous buffer" },
            { "<leader>ba", "<cmd>ball<cr>", desc = "Open all buffers" },
            { "<leader>bc", "<cmd>bdelete<cr><cmd>bnext<cr>", desc = "Close buffer and go to next" },
            { "<leader>bC", "<cmd>%bd|e#|bd#<cr>", desc = "Close all buffers except current" },
            { "<leader>`", "<cmd>b#<cr>", desc = "Toggle between buffers" },
            
            -- Save mappings (moved to avoid conflict with window group)
            { "<leader>s", "<cmd>w<cr>", desc = "Save file" },
            { "<leader>S", "<cmd>wa<cr>", desc = "Save all files" },
            
            -- Window management
            { "<leader>wd", "<C-W>c", desc = "Delete window" },
            { "<leader>w-", "<C-W>s", desc = "Split window below" },
            { "<leader>w|", "<C-W>v", desc = "Split window right" },
            { "<leader>ww", "<C-W>w", desc = "Switch windows" },
            { "<leader>wh", "<C-W>h", desc = "Go to left window" },
            { "<leader>wj", "<C-W>j", desc = "Go to lower window" },
            { "<leader>wk", "<C-W>k", desc = "Go to upper window" },
            { "<leader>wl", "<C-W>l", desc = "Go to right window" },
            
            -- Tab management
            { "<leader>tn", "<cmd>tabnew<cr>", desc = "New tab" },
            { "<leader>tc", "<cmd>tabclose<cr>", desc = "Close tab" },
            { "<leader>to", "<cmd>tabonly<cr>", desc = "Close other tabs" },
            { "<leader>th", "<cmd>tabprevious<cr>", desc = "Previous tab" },
            { "<leader>tl", "<cmd>tabnext<cr>", desc = "Next tab" },
            
            -- File explorer
            { "<leader>e", "<cmd>Oil<cr>", desc = "Open file explorer (Oil)" },
            { "<leader>E", "<cmd>Oil .<cr>", desc = "Open Oil in current directory" },
            { "-", "<cmd>Oil<cr>", desc = "Open parent directory" },
            
            -- Select all
            { "<C-a>", "ggVG", desc = "Select all text" },
            
            -- Rust specific (only active in rust files)
            { "<leader>rc", 
                function()
                    if vim.bo.filetype == "rust" then
                        vim.cmd("RustLsp flyCheck")
                    end
                end, 
                desc = "Run cargo check (Rust)" 
            },
            { "<leader>rf", 
                function()
                    if vim.bo.filetype == "rust" then
                        vim.lsp.buf.format({ async = false })
                        vim.notify("Formatted Rust file", vim.log.levels.INFO)
                    end
                end, 
                desc = "Format Rust file" 
            },
            
            -- Register group names
            { "<leader>b", group = "buffer" },
            { "<leader>q", group = "quit" },
            { "<leader>w", group = "window" },
            { "<leader>t", group = "tab" },
            { "<leader>r", group = "rust/recent" },
            { "<leader>h", group = "harpoon" },
        })
    end,
}