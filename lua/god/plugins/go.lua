return {
    'ray-x/go.nvim',
    dependencies = {
        'ray-x/guihua.lua',
        'neovim/nvim-lspconfig',
        'nvim-treesitter/nvim-treesitter',
    },
    ft = { 'go', 'gomod' },
    build = ':lua require("go.install").update_all_sync()',
    config = function()
        require('go').setup({
            go = 'go',
            goimports = 'gopls',
            fillstruct = 'gopls',
            gofmt = 'golines', -- Changed to golines to make max_line_len effective
            max_line_len = 120,
            tag_transform = false,
            tag_options = 'json=omitempty',
            gotests_template = "",
            gotests_template_dir = "",
            comment_placeholder = '',
            icons = { breakpoint = '🧘', currentpos = '🏃' },
            verbose = false,
            lsp_cfg = {
                capabilities = require('blink.cmp').get_lsp_capabilities(),
                settings = {
                    gopls = {
                        experimentalPostfixCompletions = true,
                        analyses = {
                            unusedparams = true,
                            shadow = true,
                        },
                        staticcheck = true,
                        gofumpt = true,
                    },
                },
            },
            lsp_gofumpt = true,
            lsp_on_attach = nil,
            lsp_keymaps = false,
            lsp_codelens = true,
            lsp_diag_hdlr = true,
            lsp_diag_underline = true,
            lsp_diag_virtual_text = { space = 0, prefix = '■' },
            lsp_diag_signs = true,
            lsp_diag_update_in_insert = false,
            lsp_document_formatting = true,
            lsp_inlay_hints = {
                enable = true,
                only_current_line = false,
                only_current_line_autocmd = "CursorHold",
                show_variable_name = true,
                parameter_hints_prefix = "󰊕 ",
                show_parameter_hints = true,
                other_hints_prefix = "=> ",
                max_len_align = false,
                max_len_align_padding = 1,
                right_align = false,
                right_align_padding = 6,
                highlight = "Comment",
            },
            gopls_cmd = nil,
            gopls_remote_auto = true,
            gocoverage_sign = "█",
            sign_priority = 5,
            dap_debug = true,
            dap_debug_keymap = true,
            dap_debug_gui = {},
            dap_debug_vt = { enabled_commands = true, all_frames = true },
            dap_port = 38697,
            dap_timeout = 15,
            dap_retries = 20,
            build_tags = "tag1,tag2",
            textobjects = true,
            test_runner = 'go',
            verbose_tests = true,
            run_in_floaterm = false,
            floaterm = {
                posititon = 'auto',
                width = 0.45,
                height = 0.98,
                title_colors = 'nord',
            },
            trouble = false,
            test_efm = false,
            luasnip = false,
            iferr_vertical_shift = 4,
        })
        
        -- Go specific keymaps
        vim.api.nvim_create_autocmd("FileType", {
            pattern = { "go" },
            callback = function()
                -- Run and test
                vim.keymap.set("n", "<leader>gr", "<cmd>GoRun<cr>", { buffer = true, desc = "Go Run" })
                vim.keymap.set("n", "<leader>gt", "<cmd>GoTest<cr>", { buffer = true, desc = "Go Test" })
                vim.keymap.set("n", "<leader>gT", "<cmd>GoTestFunc<cr>", { buffer = true, desc = "Go Test Function" })
                vim.keymap.set("n", "<leader>gf", "<cmd>GoTestFile<cr>", { buffer = true, desc = "Go Test File" })
                vim.keymap.set("n", "<leader>gp", "<cmd>GoTestPkg<cr>", { buffer = true, desc = "Go Test Package" })
                
                -- Code generation
                vim.keymap.set("n", "<leader>gc", "<cmd>GoCoverage<cr>", { buffer = true, desc = "Go Coverage" })
                vim.keymap.set("n", "<leader>gC", "<cmd>GoCoverageClear<cr>", { buffer = true, desc = "Go Coverage Clear" })
                vim.keymap.set("n", "<leader>gi", "<cmd>GoImpl<cr>", { buffer = true, desc = "Go Implement Interface" })
                vim.keymap.set("n", "<leader>gs", "<cmd>GoFillStruct<cr>", { buffer = true, desc = "Go Fill Struct" })
                vim.keymap.set("n", "<leader>ge", "<cmd>GoIfErr<cr>", { buffer = true, desc = "Go If Err" })
                
                -- Import management
                vim.keymap.set("n", "<leader>ga", "<cmd>GoImport<cr>", { buffer = true, desc = "Go Add Import" })
                vim.keymap.set("n", "<leader>gA", "<cmd>GoImports<cr>", { buffer = true, desc = "Go Format Imports" })
                
                -- Tags
                vim.keymap.set("n", "<leader>gj", "<cmd>GoAddTag<cr>", { buffer = true, desc = "Go Add Tags" })
                vim.keymap.set("n", "<leader>gJ", "<cmd>GoRmTag<cr>", { buffer = true, desc = "Go Remove Tags" })
                
                -- Debugging
                vim.keymap.set("n", "<leader>gd", "<cmd>GoDebug<cr>", { buffer = true, desc = "Go Debug" })
                vim.keymap.set("n", "<leader>gb", "<cmd>GoBreakToggle<cr>", { buffer = true, desc = "Go Toggle Breakpoint" })
                vim.keymap.set("n", "<leader>gB", "<cmd>GoDebug -s<cr>", { buffer = true, desc = "Go Debug Stop" })
                
                -- Documentation
                vim.keymap.set("n", "<leader>gD", "<cmd>GoDoc<cr>", { buffer = true, desc = "Go Doc" })
                
                -- Misc
                vim.keymap.set("n", "<leader>gm", "<cmd>GoMod<cr>", { buffer = true, desc = "Go Mod" })
                vim.keymap.set("n", "<leader>gv", "<cmd>GoVet<cr>", { buffer = true, desc = "Go Vet" })
                vim.keymap.set("n", "<leader>gl", "<cmd>GoLint<cr>", { buffer = true, desc = "Go Lint" })
                vim.keymap.set("n", "<leader>gg", "<cmd>GoGet<cr>", { buffer = true, desc = "Go Get" })
            end,
        })
    end,
}