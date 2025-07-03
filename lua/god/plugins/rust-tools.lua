return {
    -- Rust-specific tools and enhancements
    {
        'mrcjkb/rustaceanvim',
        version = '^4',
        ft = { 'rust' },
        config = function()
            vim.g.rustaceanvim = {
                -- Plugin configuration
                tools = {
                    hover_actions = {
                        auto_focus = true,
                    },
                },
                -- LSP configuration
                server = {
                    on_attach = function(client, bufnr)
                        -- Format on save with rustfmt and organize imports
                        vim.api.nvim_create_autocmd("BufWritePre", {
                            buffer = bufnr,
                            callback = function()
                                -- Format with rustfmt (includes import organization)
                                vim.lsp.buf.format({ async = false })
                                
                                -- Run code actions to fix clippy suggestions
                                -- This includes converting to Self references where appropriate
                                local params = vim.lsp.util.make_range_params()
                                params.context = {
                                    diagnostics = vim.lsp.diagnostic.get_line_diagnostics(),
                                    only = { "source.fixAll.clippy" }
                                }
                                
                                local result = vim.lsp.buf_request_sync(bufnr, "textDocument/codeAction", params, 1000)
                                if result then
                                    for _, res in pairs(result) do
                                        if res.result then
                                            for _, action in pairs(res.result) do
                                                if action.edit then
                                                    vim.lsp.util.apply_workspace_edit(action.edit, "utf-8")
                                                end
                                            end
                                        end
                                    end
                                end
                            end,
                            desc = "Format Rust file and apply clippy fixes on save",
                        })
                    end,
                    default_settings = {
                        -- rust-analyzer settings
                        ['rust-analyzer'] = {
                            -- Enable all features
                            cargo = {
                                allFeatures = true,
                                loadOutDirsFromCheck = true,
                                runBuildScripts = true,
                            },
                            -- Add clippy lints
                            check = {
                                command = "clippy",
                                extraArgs = {
                                    "--",
                                    "-W", "clippy::all",
                                    "-W", "clippy::pedantic",
                                    "-W", "clippy::nursery",
                                    "-A", "clippy::module_name_repetitions",
                                    "-A", "clippy::must_use_candidate",
                                },
                            },
                            procMacro = {
                                enable = true,
                            },
                            diagnostics = {
                                enable = true,
                                experimental = {
                                    enable = true,
                                },
                            },
                            -- Import settings
                            imports = {
                                granularity = {
                                    group = "module",
                                },
                                prefix = "self",
                            },
                            -- Assist settings to help with code actions
                            assist = {
                                importEnforceGranularity = true,
                                importPrefix = "self",
                                expressionFillDefault = "todo",
                            },
                            -- Inlay hints
                            inlayHints = {
                                bindingModeHints = {
                                    enable = false,
                                },
                                chainingHints = {
                                    enable = true,
                                },
                                closingBraceHints = {
                                    enable = true,
                                    minLines = 25,
                                },
                                closureReturnTypeHints = {
                                    enable = "never",
                                },
                                lifetimeElisionHints = {
                                    enable = "never",
                                    useParameterNames = false,
                                },
                                maxLength = 25,
                                parameterHints = {
                                    enable = true,
                                },
                                reborrowHints = {
                                    enable = "never",
                                },
                                renderColons = true,
                                typeHints = {
                                    enable = true,
                                    hideClosureInitialization = false,
                                    hideNamedConstructor = false,
                                },
                            },
                        },
                    },
                },
                -- DAP configuration
                dap = {
                },
            }
        end,
    },
    
    -- Better TOML support for Cargo.toml files
    {
        'saecki/crates.nvim',
        event = { "BufRead Cargo.toml" },
        config = function()
            require('crates').setup({
                popup = {
                    autofocus = true,
                    border = "rounded",
                },
            })
        end,
    },
}