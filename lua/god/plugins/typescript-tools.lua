return {
    'pmizio/typescript-tools.nvim',
    dependencies = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' },
    ft = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
    opts = {
        settings = {
            separate_diagnostic_server = true,
            publish_diagnostic_on = "insert_leave",
            expose_as_code_action = {},
            tsserver_path = nil,
            tsserver_plugins = {},
            tsserver_max_memory = "auto",
            tsserver_format_options = {},
            tsserver_file_preferences = {
                includeInlayParameterNameHints = "all",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayVariableTypeHintsWhenTypeMatchesName = false,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
                includeCompletionsForModuleExports = true,
                quotePreference = "auto",
            },
            tsserver_locale = "en",
            complete_function_calls = false,
            include_completions_with_insert_text = true,
            code_lens = "off",
            disable_member_code_lens = true,
            jsx_close_tag = {
                enable = true,
                filetypes = { "javascriptreact", "typescriptreact" },
            }
        },
    },
    config = function(_, opts)
        require("typescript-tools").setup(opts)
        
        -- TypeScript specific keymaps
        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("TypeScriptTools", { clear = true }),
            callback = function(ev)
                local client = vim.lsp.get_client_by_id(ev.data.client_id)
                if client and client.name == "typescript-tools" then
                    local function map(mode, lhs, rhs, desc)
                        vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, desc = desc })
                    end
                    
                    -- TypeScript specific commands
                    map("n", "<leader>to", "<cmd>TSToolsOrganizeImports<cr>", "Organize Imports")
                    map("n", "<leader>ts", "<cmd>TSToolsSortImports<cr>", "Sort Imports")
                    map("n", "<leader>tu", "<cmd>TSToolsRemoveUnused<cr>", "Remove Unused")
                    map("n", "<leader>td", "<cmd>TSToolsRemoveUnusedImports<cr>", "Remove Unused Imports")
                    map("n", "<leader>tf", "<cmd>TSToolsFixAll<cr>", "Fix All")
                    map("n", "<leader>ta", "<cmd>TSToolsAddMissingImports<cr>", "Add Missing Imports")
                    map("n", "<leader>tr", "<cmd>TSToolsRenameFile<cr>", "Rename File")
                    map("n", "<leader>tg", "<cmd>TSToolsGoToSourceDefinition<cr>", "Go to Source Definition")
                    
                    -- File references
                    map("n", "<leader>tR", "<cmd>TSToolsFileReferences<cr>", "File References")
                end
            end,
        })
    end,
}