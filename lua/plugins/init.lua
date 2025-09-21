return {
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = false,
    priority = 1000,
    opts = {
      variant = "auto",
      dark_variant = "main",
      enable = {
        terminal = true,
      },
      styles = {
        transparency = true,
      },
    },
    config = function(_, opts)
      require("rose-pine").setup(opts)
      vim.cmd.colorscheme("rose-pine")
    end,
  },
  {
    "dmtrKovalenko/fff.nvim",
    build = "cargo build --release",
    lazy = false,
    config = function()
      require("mini.icons").mock_nvim_web_devicons()
    end,
    keys = {
      { "ff", function() require("fff").find_files() end, desc = "Find files" },
      { "<leader><leader>", function() require("fff").find_files() end, desc = "Find files" },
    },
  },
  {"ibhagwan/fzf-lua"},
  {'j-morano/buffer_manager.nvim', dependencies = {'nvim-lua/plenary.nvim'}},
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      -- Modern bigfile handling
      bigfile = { enabled = true },
      -- Dim everything but active scope
      dim = { enabled = true },
      -- simple buffer delete
      bufdelete = { enabled = true },
      -- Enhanced dashboard
      dashboard = { -- enable when i disable alpha
        enabled = true,
        sections = {
          { section = "terminal", cmd = "fortune -s | cowsay", hl = "header", padding = 1, indent = 8 },
          { section = "keys", gap = 1, padding = 1 },
        },
        keys = {
          {
            key = "ff",
            desc = "Find files",
            action = function()
              require("fff").find_files()
            end,
          },
        },
      },
      -- Modern indent guides
      indent = { enabled = true },
      -- Enable image viewing
      image = { enabled = true },
      -- Enhanced input handling
      input = { enabled = true },
      -- Modern notifications
      notifier = { enabled = true },
      -- Enhanced quickfix
      quickfile = { enabled = true },
      -- Modern scroll improvements
      scroll = { enabled = true },
      -- Enhanced statuscolumn
      statuscolumn = { enabled = true },
      -- Modern toggle functionality
      toggle = { enabled = true },
      -- Enhanced words highlighting
      words = { enabled = true },
      -- Zen mode
      zen = { enabled = true },
      -- toggle terminals
      terminal = { enabled = true },
      -- Lazygit enabled
      lazygit = { enabled = true, configure = true },
    },
    keys = {
      { "<leader>bd", function() Snacks.bufdelete() end, desc = "Delete Buffer" },
      { "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit" },
      { "<leader>gb", function() Snacks.git.blame_line() end, desc = "Git Blame Line" },
      { "<C-\\>", function() Snacks.terminal() end, desc = "Terminal" },
    }
    
  },
  {
    "stevearc/oil.nvim",
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {
      default_file_explorer = true,
      delete_to_trash = true,
      skip_confirm_for_simple_edits = true,
      cleanup_delay_ms = 100, -- Reduced from 1_000ms for better performance
      use_default_keymaps = true,
      view_options = {
        show_hidden = false,
        is_always_hidden = function(name)
          return vim.startswith(name, ".git")
        end,
      },
      win_options = {
        signcolumn = "auto",
      },
      keymaps = {
        ["<C-s>"] = {
          callback = function()
            require("oil").save()
          end,
          mode = "n",
          desc = "Save changes in Oil",
        },
      },
    },
    dependencies = {
      { "echasnovski/mini.icons", opts = {} },
    },
    lazy = false,
    keys = {
      { "<leader>o", function() require("oil").open() end, desc = "Open oil" },
      { "<leader>e", function() require("oil").open() end, desc = "Open oil" },
    },
  },
  {
    "benomahony/oil-git.nvim",
    dependencies = { "stevearc/oil.nvim" },
    config = function()
      require("oil-git").setup()
    end,
  },
  {
    "folke/lazydev.nvim",
    ft = "lua",
    dependencies = {
      { "Bilal2453/luvit-meta", lazy = true },
    },
    opts = {
      library = {
        -- Make the luvit types available for better Lua completion.
        { path = "luvit-meta/library", words = { "vim" } },
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      ensure_installed = {
        "bash",
        "css",
        "html",
        "javascript",
        "json",
        "lua",
        "rust",
        "markdown",
        "markdown_inline",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "yaml",
      },
      highlight = { enable = true },
      indent = { enable = true },
      autotag = { enable = true },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },
  {
    "windwp/nvim-ts-autotag",
    event = "VeryLazy",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {},
    config = function(_, opts)
      require("nvim-ts-autotag").setup(opts)
    end,
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "quarto", "rmd" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {},
    config = function(_, opts)
      require("render-markdown").setup(opts)
    end,
  },
  {
    "mason-org/mason.nvim",
    build = ":MasonUpdate",
    opts = {
      ui = {
        border = "rounded",
        icons = {
          package_installed = "*",
          package_pending = ">",
          package_uninstalled = "x",
        },
      },
      PATH = "prepend",
    },
  },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = { "mason-org/mason.nvim" },
  },
  {
    "mrcjkb/rustaceanvim",
    version = "^6",
    ft = { "rust" },
    init = function()
      local lsp = require("config.lsp")
      vim.g.rustaceanvim = {
        tools = {
          enable_clippy = true,
        },
        server = {
          capabilities = lsp.capabilities(),
          on_attach = lsp.on_attach,
          ra_multiplex = {
            enable = true,
            host = "127.0.0.1",
            port = 27631,
          },
          default_settings = {
            ["rust-analyzer"] = {
              check = {
                command = "clippy",
                extraArgs = { "--all-features" },
              },
              cargo = {
                allFeatures = true,
                buildScripts = {
                  enable = true,
                },
              },
              diagnostics = {
                experimental = {
                  enable = true,
                },
              },
              inlayHints = {
                bindingModeHints = {
                  enable = true,
                },
                closureStyle = "impl_fn",
                closingBraceHints = {
                  enable = true,
                  minLines = 25,
                },
                lifetimeElisionHints = {
                  enable = "skip_trivial",
                },
                maxLength = 25,
              },
            },
          },
        },
      }
    end,
  },
  {
    "saecki/crates.nvim",
    event = { "BufReadPre Cargo.toml" },
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local crates = require("crates")
      crates.setup({})

      local group = vim.api.nvim_create_augroup("CratesExtras", { clear = true })
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
        group = group,
        pattern = "Cargo.toml",
        callback = function(event)
          local ok, mapped = pcall(vim.api.nvim_buf_get_var, event.buf, "crates_mapped")
          if ok and mapped then return end
          -- Buffer-local mappings to manage crate versions quickly
          local function buf_map(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { buffer = event.buf, desc = desc })
          end
          buf_map("<leader>cu", crates.update_crate, "Update crate under cursor")
          buf_map("<leader>cU", crates.update_all_crates, "Update all crates")
          buf_map("<leader>cv", crates.show_versions_popup, "Show crate versions")
          buf_map("<leader>cf", crates.show_features_popup, "Show crate features")
          buf_map("<leader>cd", crates.open_documentation, "Open crate documentation")

          vim.api.nvim_buf_set_var(event.buf, "crates_mapped", true)
        end,
      })
    end,
  },
  {
    "saghen/blink.cmp",
    build = "cargo build --release",
    dependencies = { "rafamadriz/friendly-snippets" },
    opts = {
      keymap = { preset = "super-tab" },
      appearance = { nerd_font_variant = "mono" },
      completion = { documentation = { auto_show = false } },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        providers = {
          snippets = {
            should_show_items = function(ctx)
              local start_col = ctx.bounds and ctx.bounds.start_col or 1
              if start_col <= 1 then return true end

              local line = ctx.line or ""
              local previous_char = line:sub(start_col - 1, start_col - 1)
              return previous_char ~= "."
            end,
          },
        },
      },
      fuzzy = {
        implementation = "rust",
        frecency = {
          enabled = true,
          path = vim.fn.stdpath("state") .. "/blink-cmp/frecency/frecency.dat",
        },
      },
    },
    opts_extend = { "sources.default" },
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
    config = function(_, opts)
      require("nvim-autopairs").setup(opts)
    end,
  },
  {
    "supermaven-inc/supermaven-nvim",
    event = "InsertEnter",
    cmd = {
      "SupermavenStart",
      "SupermavenStop",
      "SupermavenToggle",
      "SupermavenRestart",
    },
    opts = {
      log_level = "off",
      disable_keymaps = true,
    },
    config = function(_, opts)
      local supermaven = require("supermaven-nvim")
      supermaven.setup(opts)

      local completion = require("supermaven-nvim.completion_preview")
      local termcodes = function(str)
        return vim.api.nvim_replace_termcodes(str, true, false, true)
      end

      vim.keymap.set("i", "<C-]>", function()
        if completion.has_suggestion() then
          vim.schedule(function()
            completion.on_accept_suggestion()
          end)
          return ""
        end
        return termcodes("<C-]>")
      end, { expr = true, silent = true, desc = "Supermaven accept suggestion" })

    end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
      "saghen/blink.cmp",
      "b0o/schemastore.nvim",
    },
    opts = {
      ensure_installed = {
        "lua_ls",
        "tsserver",
        "eslint",
        "pyright",
        "gopls",
        "yamlls",
        "jsonls",
        "dockerls",
        "html",
        "cssls",
        "emmet_language_server",
      },
      servers = {
        lua_ls = {
          settings = {
            Lua = {
              completion = { callSnippet = "Replace" },
              diagnostics = { globals = { "vim" } },
              workspace = { checkThirdParty = false },
            },
          },
        },
        tsserver = { enabled = false },
        eslint = {
          settings = {
            workingDirectory = { mode = "auto" },
          },
        },
        pyright = {
          settings = {
            python = {
              analysis = {
                autoImportCompletions = true,
                useLibraryCodeForTypes = true,
                typeCheckingMode = "basic",
              },
            },
          },
        },
        gopls = {
          settings = {
            gopls = {
              gofumpt = true,
              semanticTokens = true,
              staticcheck = true,
            },
          },
        },
        yamlls = {
          settings = require("config.lsp.schemas").yaml(),
        },
        jsonls = {
          settings = require("config.lsp.schemas").json(),
        },
        dockerls = {},
        html = {
          on_attach = function(client)
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
          end,
        },
        cssls = {},
        emmet_language_server = {
          filetypes = {
            "css",
            "html",
            "javascript",
            "javascriptreact",
            "sass",
            "scss",
            "typescript",
            "typescriptreact",
          },
        },
      },
    },
    config = function(_, opts)
      local lsp = require("config.lsp")
      local lspconfig = require("lspconfig")
      local mason_lspconfig = require("mason-lspconfig")

      local servers = opts.servers or {}

      mason_lspconfig.setup({
        ensure_installed = opts.ensure_installed or vim.tbl_keys(servers),
        automatic_installation = false,
      })

      mason_lspconfig.setup_handlers({
        function(server_name)
          local server_opts = vim.tbl_deep_extend("force", {}, servers[server_name] or {})
          if server_opts.enabled == false then
            return
          end

          server_opts.enabled = nil
          server_opts.capabilities = vim.tbl_deep_extend(
            "force",
            {},
            server_opts.capabilities or {},
            lsp.capabilities()
          )

          local existing_on_attach = server_opts.on_attach
          if existing_on_attach then
            server_opts.on_attach = function(client, bufnr)
              existing_on_attach(client, bufnr)
              lsp.on_attach(client, bufnr)
            end
          else
            server_opts.on_attach = lsp.on_attach
          end

          lspconfig[server_name].setup(server_opts)
        end,
      })
    end,
  },
  {
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
    opts = function()
      local lsp = require("config.lsp")
      return {
        on_attach = function(client, bufnr)
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false
          lsp.on_attach(client, bufnr)
        end,
        capabilities = lsp.capabilities(),
        settings = {
          expose_as_code_action = "all",
          complete_function_calls = true,
          tsserver_file_preferences = {
            includeCompletionsForModuleExports = true,
            includeCompletionsWithSnippetText = true,
            includeCompletionsWithClassMemberSnippets = true,
            includeInlayParameterNameHints = "all",
            includeInlayParameterNameHintsWhenArgumentMatchesName = false,
            includeInlayFunctionParameterTypeHints = true,
            includeInlayVariableTypeHints = true,
            includeInlayPropertyDeclarationTypeHints = true,
            includeInlayFunctionLikeReturnTypeHints = true,
            includeInlayEnumMemberValueHints = true,
            jsxAttributeCompletionStyle = "auto",
          },
        },
      }
    end,
    config = function(_, opts)
      require("typescript-tools").setup(opts)
    end,
  },
  {
    "mattn/emmet-vim",
    ft = {
      "css",
      "html",
      "javascript",
      "javascriptreact",
      "sass",
      "scss",
      "typescript",
      "typescriptreact",
    },
    init = function()
      vim.g.user_emmet_install_global = 0
      vim.g.user_emmet_leader_key = "<C-e>"
      vim.g.user_emmet_settings = {
        javascript = { extends = "jsx" },
        typescript = { extends = "tsx" },
        javascriptreact = { extends = "jsx" },
        typescriptreact = { extends = "tsx" },
      }
    end,
    config = function()
      local group = vim.api.nvim_create_augroup("EmmetAttach", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = {
          "css",
          "html",
          "javascript",
          "javascriptreact",
          "sass",
          "scss",
          "typescript",
          "typescriptreact",
        },
        callback = function()
          vim.cmd.EmmetInstall()
        end,
      })
    end,
  },
  {
    "mbbill/undotree",
    keys = {
      { "<leader>u", function() vim.cmd.UndotreeToggle() end, desc = "Toggle Undotree" },
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    init = function()
      require("config.lualine").init()
    end,
    opts = function()
      return require("config.lualine").opts()
    end,
    config = function(_, opts)
      require("lualine").setup(opts)
      require("config.lualine").post_setup()
    end,
  },
}
