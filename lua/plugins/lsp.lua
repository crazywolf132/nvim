-- plugins/lsp.lua
-- LSP and completion plugins setup

return {
  -- Mason to install LSPs/linters/formatters
  { 
    'williamboman/mason.nvim', 
    config = true 
  },
  
  -- Mason LSP config integration
  { 
    'williamboman/mason-lspconfig.nvim', 
    dependencies = { 'mason.nvim' },
    config = function()
      require('mason-lspconfig').setup({
        ensure_installed = { 
          'rust_analyzer', 'gopls', 'lua_ls',
          'ts_ls', 'html', 'cssls', 'marksman',
          'emmet_ls', 'eslint', 'tailwindcss', 'jsonls'
        },
        automatic_installation = true,
      })
    end
  },
  
  -- LSPconfig
  { 
    'neovim/nvim-lspconfig', 
    dependencies = { 'mason-lspconfig.nvim' },
    config = function()
      local lsp = require('lspconfig')
      
      -- Common on_attach for all LSPs
      local on_attach = function(client, bufnr)
        -- Keybindings for LSP (only active in LSP buffers)
        local bufmap = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end
        
        bufmap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', 'Go to Definition')
        bufmap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', 'Hover Documentation')
        bufmap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', 'Find References')
        bufmap('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', 'Rename Symbol')
        bufmap('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', 'Code Action')
        bufmap('n', '<C-.>', '<cmd>lua vim.lsp.buf.code_action()<CR>', 'Code Action (Ctrl+.)')
        bufmap('n', '<D-.>', '<cmd>lua vim.lsp.buf.code_action()<CR>', 'Code Action (Cmd+.)')
        bufmap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', 'Previous Diagnostic')
        bufmap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', 'Next Diagnostic')
        
        -- Enable inlay hints for Neovim 0.11+
        if vim.lsp.inlay_hint and vim.lsp.inlay_hint.enable then 
          vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
        end
        
        -- Format on save for LSP servers that support formatting
        if client.supports_method("textDocument/formatting") then
          -- Skip if null-ls is attached (to avoid conflicts)
          local null_ls_attached = false
          for _, c in pairs(vim.lsp.get_clients({ bufnr = bufnr })) do
            if c.name == "null-ls" then
              null_ls_attached = true
              break
            end
          end
          
          if not null_ls_attached then
            local augroup = vim.api.nvim_create_augroup("LspFormatting", { clear = false })
            vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
            vim.api.nvim_create_autocmd("BufWritePre", {
              group = augroup,
              buffer = bufnr,
              callback = function()
                vim.lsp.buf.format({ 
                  bufnr = bufnr,
                  timeout_ms = 2000,
                })
              end
            })
          end
        end
      end
      
      -- LSP server setups
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      
      -- Try to get blink.cmp capabilities if available
      local ok, blink = pcall(require, 'blink.cmp')
      if ok then
        capabilities = blink.get_lsp_capabilities(capabilities)
      end
      
      -- Rust (handled by rustaceanvim - see below)
      -- Note: rustaceanvim handles rust-analyzer setup automatically
      -- The advanced setup below provides better Rust development features
      
      -- Go
      lsp.gopls.setup {
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          gopls = {
            gofumpt = true,  -- use gofumpt stricter format
            analyses = { unusedparams = true },
            staticcheck = true,
          }
        }
      }
      
      -- TypeScript/JavaScript (fallback - disabled when typescript-tools.nvim is loaded)
      -- Note: This will be automatically disabled by typescript-tools.nvim to prevent conflicts
      if not pcall(require, 'typescript-tools') then
        lsp.ts_ls.setup { 
          on_attach = on_attach,
          capabilities = capabilities,
          settings = {
            typescript = {
              inlayHints = {
                includeInlayParameterNameHints = 'literals',
                includeInlayFunctionParameterTypeHints = false,
                includeInlayVariableTypeHints = false,
                includeInlayPropertyDeclarationTypeHints = false,
                includeInlayFunctionLikeReturnTypeHints = false,
                includeInlayEnumMemberValueHints = false,
              }
            },
            javascript = {
              inlayHints = {
                includeInlayParameterNameHints = 'literals',
                includeInlayFunctionParameterTypeHints = false,
                includeInlayVariableTypeHints = false,
                includeInlayPropertyDeclarationTypeHints = false,
                includeInlayFunctionLikeReturnTypeHints = false,
                includeInlayEnumMemberValueHints = false,
              }
            }
          }
        }
      end
      
      -- HTML/CSS/Web Development
      lsp.html.setup { 
        on_attach = on_attach, 
        capabilities = capabilities,
        filetypes = { "html", "templ" },
      }
      
      lsp.cssls.setup { 
        on_attach = on_attach, 
        capabilities = capabilities,
        settings = {
          css = {
            validate = true,
            lint = {
              unknownAtRules = "ignore"
            }
          },
          scss = {
            validate = true,
            lint = {
              unknownAtRules = "ignore"
            }
          },
          less = {
            validate = true,
            lint = {
              unknownAtRules = "ignore"
            }
          },
        },
      }
      
      -- Emmet for HTML/CSS/JSX
      lsp.emmet_ls.setup {
        on_attach = on_attach,
        capabilities = capabilities,
        filetypes = { 
          "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less", "vue", "svelte" 
        },
        init_options = {
          html = {
            options = {
              -- For possible options, see: https://github.com/emmetio/emmet/blob/master/src/config.ts#L79-L267
              ["bem.enabled"] = true,
            },
          },
        }
      }
      
      -- ESLint
      lsp.eslint.setup {
        on_attach = function(client, bufnr)
          on_attach(client, bufnr)
          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            command = "EslintFixAll",
          })
        end,
        capabilities = capabilities,
        settings = {
          codeAction = {
            disableRuleComment = {
              enable = true,
              location = "separateLine"
            },
            showDocumentation = {
              enable = true
            }
          },
          codeActionOnSave = {
            enable = false,
            mode = "all"
          },
          experimental = {
            useFlatConfig = false
          },
          format = true,
          nodePath = "",
          onIgnoredFiles = "off",
          packageManager = "npm",
          problems = {
            shortenToSingleLine = false
          },
          quiet = false,
          rulesCustomizations = {},
          run = "onType",
          useESLintClass = false,
          validate = "on",
          workingDirectory = {
            mode = "location"
          }
        }
      }
      
      -- TailwindCSS
      lsp.tailwindcss.setup {
        on_attach = on_attach,
        capabilities = capabilities,
        filetypes = { 
          "html", "css", "scss", "javascript", "javascriptreact", "typescript", "typescriptreact", "vue", "svelte" 
        },
        settings = {
          tailwindCSS = {
            classAttributes = { "class", "className", "class:list", "classList", "ngClass" },
            lint = {
              cssConflict = "warning",
              invalidApply = "error",
              invalidConfigPath = "error",
              invalidScreen = "error",
              invalidTailwindDirective = "error",
              invalidVariant = "error",
              recommendedVariantOrder = "warning"
            },
            validate = true
          }
        }
      }
      
      -- JSON (with schema support)
      lsp.jsonls.setup {
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          json = {
            validate = { enable = true },
          },
        },
      }
      
      -- Markdown (marksman)
      lsp.marksman.setup { 
        on_attach = on_attach, 
        capabilities = capabilities 
      }
      
      -- Lua LSP (for Neovim config)
      lsp.lua_ls.setup {
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          Lua = {
            workspace = { checkThirdParty = false },
            diagnostics = { globals = { "vim" } },
            telemetry = { enable = false },
          }
        }
      }
    end
  },
  
  -- Mason-null-ls bridge for auto-linking formatters/linters
  {
    'jay-babu/mason-null-ls.nvim',
    dependencies = { 'mason.nvim' },
    config = function()
      require('mason-null-ls').setup({
        ensure_installed = { 
          'prettier', 'eslint_d', 'stylua',
          'gofumpt', 'goimports', 'markdownlint'
        },
        automatic_installation = true,
      })
    end
  },

  -- None-ls (maintained fork of null-ls) for formatters/linters
  { 
    'nvimtools/none-ls.nvim',
    dependencies = { 'nvim-lua/plenary.nvim', 'mason-null-ls.nvim' },
    config = function()
      local null_ls = require('null-ls')
      
      -- Build sources list dynamically to handle optional tools
      local sources = {}
      
      -- Prettier formatting
      if null_ls.builtins.formatting.prettier then
        table.insert(sources, null_ls.builtins.formatting.prettier.with({
          condition = function(utils)
            return utils.root_has_file({ ".prettierrc", ".prettierrc.json", ".prettierrc.js", "prettier.config.js", "package.json" })
          end,
        }))
      end
      
      -- ESLint diagnostics (check if available)
      if pcall(require, "null-ls.builtins.diagnostics.eslint_d") then
        table.insert(sources, null_ls.builtins.diagnostics.eslint_d.with({
          condition = function(utils)
            return utils.root_has_file({ ".eslintrc", ".eslintrc.json", ".eslintrc.js", "eslint.config.js", ".eslintrc.yaml", ".eslintrc.yml", "package.json" })
          end,
        }))
      end
      
      -- Go formatters
      if null_ls.builtins.formatting.gofumpt then
        table.insert(sources, null_ls.builtins.formatting.gofumpt)
      end
      if null_ls.builtins.formatting.goimports then
        table.insert(sources, null_ls.builtins.formatting.goimports)
      end
      
      -- Markdown linting
      if null_ls.builtins.diagnostics.markdownlint then
        table.insert(sources, null_ls.builtins.diagnostics.markdownlint)
      end
      
      null_ls.setup({
        sources = sources,
        on_attach = function(client, bufnr)
          if client.supports_method("textDocument/formatting") then
            -- Create buffer-local autocmd group
            local augroup = vim.api.nvim_create_augroup("LspFormatting", { clear = false })
            vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
            vim.api.nvim_create_autocmd("BufWritePre", {
              group = augroup,
              buffer = bufnr,
              callback = function()
                vim.lsp.buf.format({ 
                  bufnr = bufnr,
                  filter = function(client)
                    -- Only use null-ls for formatting
                    return client.name == "null-ls"
                  end
                })
              end
            })
          end
        end
      })
    end
  },
  
  -- Blink.cmp - Fast completion engine written in Rust
  {
    'saghen/blink.cmp',
    dependencies = 'rafamadriz/friendly-snippets',
    version = '*',
    build = 'cargo build --release',
    event = 'InsertEnter',
    opts = {
      keymap = {
        preset = 'default',
        ['<Tab>'] = { 'accept', 'fallback' },
        ['<C-Space>'] = { 'show', 'show_documentation', 'hide_documentation' },
        ['<C-j>'] = { 'select_next', 'fallback' },
        ['<C-k>'] = { 'select_prev', 'fallback' },
        ['<C-e>'] = { 'hide', 'fallback' },
      },
      
      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = 'mono',
      },
      
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
      },
      
      completion = {
        accept = {
          auto_brackets = {
            enabled = true,
          },
        },
        
        menu = {
          auto_show = true,
          border = 'rounded',
        },
        
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 500,
        },
        
        ghost_text = {
          enabled = true,
        },
      },
      
      signature = {
        enabled = true,
      },
    },
  },
  
  -- Rust crates version management
  { 
    'saecki/crates.nvim', 
    event = { "BufRead Cargo.toml" }, 
    config = true 
  },
  
  -- Advanced Rust development with rustaceanvim
  -- Provides enhanced rust-analyzer integration with extra features
  {
    'mrcjkb/rustaceanvim',
    version = '^4',
    ft = { 'rust' },
    config = function()
      vim.g.rustaceanvim = {
        -- Plugin configuration
        tools = {
          -- These apply to the default toolchain
          hover_actions = {
            auto_focus = true,
          },
        },
        -- LSP configuration
        server = {
          on_attach = function(client, bufnr)
            -- Reuse the common on_attach function defined above
            -- Note: We can't require it since it's local to this file
            
            -- LSP keybindings (copied from main on_attach)
            local bufmap = function(mode, lhs, rhs, desc)
              vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
            end
            
            bufmap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', 'Go to Definition')
            bufmap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', 'Hover Documentation')
            bufmap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', 'Find References')
            bufmap('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', 'Rename Symbol')
            bufmap('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', 'Code Action')
            bufmap('n', '<C-.>', '<cmd>lua vim.lsp.buf.code_action()<CR>', 'Code Action (Ctrl+.)')
            bufmap('n', '<D-.>', '<cmd>lua vim.lsp.buf.code_action()<CR>', 'Code Action (Cmd+.)')
            bufmap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', 'Previous Diagnostic')
            bufmap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', 'Next Diagnostic')
            
            -- Enable inlay hints for Neovim 0.11+
            if vim.lsp.inlay_hint and vim.lsp.inlay_hint.enable then 
              vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
            end
            
            -- Rustacean-specific keymaps
            vim.keymap.set("n", "<leader>ce", "<cmd>RustLsp expandMacro<cr>", { buffer = bufnr, desc = "Expand Macro" })
            vim.keymap.set("n", "<leader>ch", "<cmd>RustLsp hover actions<cr>", { buffer = bufnr, desc = "Hover Actions" })
            vim.keymap.set("n", "<leader>cH", "<cmd>RustLsp hover range<cr>", { buffer = bufnr, desc = "Hover Range" })
            vim.keymap.set("n", "<leader>cE", "<cmd>RustLsp explainError<cr>", { buffer = bufnr, desc = "Explain Error" })
            vim.keymap.set("n", "<leader>cR", "<cmd>RustLsp runnables<cr>", { buffer = bufnr, desc = "Runnables" })
            vim.keymap.set("n", "<leader>cD", "<cmd>RustLsp debuggables<cr>", { buffer = bufnr, desc = "Debuggables" })
          end,
          default_settings = {
            -- rust-analyzer language server configuration
            ['rust-analyzer'] = {
              cargo = {
                allFeatures = true,
                loadOutDirsFromCheck = true,
                runBuildScripts = true,
              },
              -- Add clippy lints for Rust.
              checkOnSave = {
                allFeatures = true,
                command = "clippy",
                extraArgs = { "--no-deps" },
              },
              procMacro = {
                enable = true,
                ignored = {
                  ["async-trait"] = { "async_trait" },
                  ["napi-derive"] = { "napi" },
                  ["async-recursion"] = { "async_recursion" },
                },
              },
            },
          },
        },
        -- DAP configuration
        dap = {
          adapter = {
            type = "executable",
            command = "lldb-vscode",
            name = "rt_lldb",
          },
        },
      }
    end,
  },
  
  -- Optional: Enhanced TypeScript development
  -- Provides additional features like file rename on symbol rename
  -- Uncomment to use for advanced TypeScript features:
  -- {
  --   'jose-elias-alvarez/typescript.nvim',
  --   dependencies = { 'nvim-lspconfig' },
  --   ft = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
  --   config = function()
  --     require('typescript').setup({
  --       server = {
  --         on_attach = function(client, bufnr)
  --           -- Your on_attach function from above
  --           -- Plus TypeScript specific keymaps:
  --           vim.keymap.set('n', '<leader>co', '<cmd>TypescriptOrganizeImports<CR>', { buffer = bufnr, desc = 'Organize Imports' })
  --           vim.keymap.set('n', '<leader>cR', '<cmd>TypescriptRenameFile<CR>', { buffer = bufnr, desc = 'Rename File' })
  --         end,
  --         capabilities = require('cmp_nvim_lsp').default_capabilities(),
  --       }
  --     })
  --   end
  -- },

  -- Trouble.nvim - Better diagnostics and references UI
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = { "Trouble", "TroubleToggle" },
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
      { "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Symbols (Trouble)" },
      { "<leader>cl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "LSP Definitions / references / ... (Trouble)" },
      { "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location List (Trouble)" },
      { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List (Trouble)" },
    },
    config = function()
      require("trouble").setup({
        modes = {
          preview_float = {
            mode = "diagnostics",
            preview = {
              type = "float",
              relative = "editor",
              border = "rounded",
              title = "Preview",
              title_pos = "center",
              position = { 0, -2 },
              size = { width = 0.3, height = 0.3 },
              zindex = 200,
            },
          },
        },
      })
    end,
  },

  -- Neotest - Unified testing interface
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      -- Language specific adapters
      "nvim-neotest/neotest-go",
      "rouge8/neotest-rust",
      "nvim-neotest/neotest-jest",
    },
    keys = {
      { "<leader>tt", function() require("neotest").run.run() end, desc = "Run Nearest Test" },
      { "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run File Tests" },
      { "<leader>ta", function() require("neotest").run.run(vim.fn.getcwd()) end, desc = "Run All Tests" },
      { "<leader>ts", function() require("neotest").summary.toggle() end, desc = "Toggle Test Summary" },
      { "<leader>to", function() require("neotest").output.open({ enter = true, auto_close = true }) end, desc = "Show Test Output" },
      { "<leader>tO", function() require("neotest").output_panel.toggle() end, desc = "Toggle Test Output Panel" },
      { "<leader>tS", function() require("neotest").run.stop() end, desc = "Stop Test" },
      { "<leader>tw", function() require("neotest").watch.toggle(vim.fn.expand("%")) end, desc = "Toggle Test Watch" },
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-go"),
          require("neotest-rust"),
          require("neotest-jest")({
            jestCommand = "npm test --",
            jestConfigFile = "jest.config.js",
            env = { CI = true },
            cwd = function(path)
              return vim.fn.getcwd()
            end,
          }),
        },
        status = { virtual_text = true },
        output = { open_on_run = true },
        quickfix = {
          open = function()
            if require("trouble").is_open() then
              require("trouble").open("quickfix")
            else
              vim.cmd("copen")
            end
          end,
        },
      })
    end,
  },
}
