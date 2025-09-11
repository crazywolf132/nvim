return {
  -- Colorscheme
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "moon",
      dim_inactive = true,
      styles = { sidebars = "transparent", floats = "transparent" },
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd.colorscheme("tokyonight")
    end,
  },

  -- Icons for UI integrations
  { "nvim-tree/nvim-web-devicons", opts = {} },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      options = {
        theme = "auto",
        globalstatus = true,
        section_separators = "",
        component_separators = "",
        disabled_filetypes = { statusline = { "oil" } },
      },
    },
  },

  -- Git signs
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
      },
    },
  },

  -- Which-key
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = { preset = "helix", icons = { mappings = false } },
  },

  -- Telescope
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    version = false,
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = function()
      local actions = require("telescope.actions")
      return {
        defaults = {
          prompt_prefix = " ",
          selection_caret = " ",
          mappings = {
            i = {
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
            },
          },
        },
        pickers = {},
      }
    end,
  },
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",
    cond = function()
      return vim.fn.executable("make") == 1
    end,
    config = function()
      pcall(require("telescope").load_extension, "fzf")
    end,
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPost", "BufNewFile" },
    build = ":TSUpdate",
    opts = {
      ensure_installed = {
        "lua",
        "vim",
        "vimdoc",
        "bash",
        "json",
        "yaml",
        "markdown",
        "markdown_inline",
        "regex",
        "query",
        "html",
        "css",
        "javascript",
        "typescript",
        "tsx",
        "python",
        "go",
      },
      highlight = { enable = true },
      indent = { enable = true },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },

  -- File explorer (edit directories as buffers)
  {
    "stevearc/oil.nvim",
    opts = { default_file_explorer = true, columns = { "icon" } },
    keys = {
      { "-", "<cmd>Oil<cr>", desc = "Open parent directory" },
    },
  },

  -- Comments
  { "numToStr/Comment.nvim", event = "VeryLazy", opts = {} },

  -- Indentation guides
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = "VeryLazy",
    opts = { indent = { char = "▏" }, scope = { enabled = true } },
  },

  -- Autopairs
  { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },

  -- LSP + Tools
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      { "williamboman/mason.nvim", config = true },
      { "williamboman/mason-lspconfig.nvim" },
      { "folke/lazydev.nvim", ft = "lua", opts = {} },
      { "b0o/schemastore.nvim" },
    },
    config = function()
      -- Icons for diagnostics
      local signs = { Error = "", Warn = "", Hint = "", Info = "" }
      for name, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. name
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
      end

      vim.diagnostic.config({
        severity_sort = true,
        update_in_insert = false,
        virtual_text = { spacing = 2, source = "if_many" },
        float = { border = "rounded", source = "if_many" },
      })
      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
      vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
      if ok_cmp then
        capabilities = cmp_lsp.default_capabilities(capabilities)
      end

      local function set_inlay(enable, bufnr)
        local ih = vim.lsp.inlay_hint
        if not ih then return end
        local ok = pcall(ih.enable, enable, { bufnr = bufnr })
        if not ok then pcall(ih.enable, bufnr, enable) end
      end

      local function toggle_inlay(bufnr)
        local ih = vim.lsp.inlay_hint
        if not ih then return end
        local enabled = false
        if ih.is_enabled then
          local ok, res = pcall(ih.is_enabled, { bufnr = bufnr })
          if not ok then res = ih.is_enabled(bufnr) end
          enabled = res and true or false
        end
        local ok = pcall(ih.enable, not enabled, { bufnr = bufnr })
        if not ok then pcall(ih.enable, bufnr, not enabled) end
      end

      local on_attach = function(client, bufnr)
        -- Buffer-local keymaps
        local map = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
        end
        map("n", "gd", vim.lsp.buf.definition, "Goto definition")
        map("n", "gD", vim.lsp.buf.declaration, "Goto declaration")
        map("n", "gr", vim.lsp.buf.references, "References")
        map("n", "gI", vim.lsp.buf.implementation, "Goto implementation")
        map("n", "K", vim.lsp.buf.hover, "Hover")
        map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
        map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
        map("n", "<leader>uh", function() toggle_inlay(bufnr) end, "Toggle inlay hints")
        -- Use Conform for formatting with LSP fallback
        map("n", "<leader>lf", function()
          require("conform").format({ async = true, lsp_fallback = true })
        end, "Format (Conform)")

        -- Enable inlay hints if server supports
        if client.supports_method and client:supports_method("textDocument/inlayHint") then
          set_inlay(true, bufnr)
        end
      end

      local lspconfig = require("lspconfig")
      local ts_name = lspconfig["ts_ls"] and "ts_ls" or "tsserver"
      local servers = {
        lua_ls = {
          settings = {
            Lua = {
              completion = { callSnippet = "Replace" },
              diagnostics = { globals = { "vim" } },
              workspace = { checkThirdParty = false },
              hint = { enable = true },
            },
          },
        },
        [ts_name] = {},
        pyright = {},
        bashls = {},
        marksman = {},
        jsonls = {
          settings = {
            json = {
              schemas = require("schemastore").json.schemas(),
              validate = { enable = true },
            },
          },
        },
        yamlls = {
          settings = {
            yaml = {
              schemas = require("schemastore").yaml.schemas(),
              keyOrdering = false,
            },
          },
        },
      }

      require("mason").setup()
      local ensure = vim.tbl_keys(servers)
      require("mason-lspconfig").setup({ ensure_installed = ensure })

      for name, conf in pairs(servers) do
        conf.capabilities = capabilities
        conf.on_attach = on_attach
        lspconfig[name].setup(conf)
      end
    end,
  },

  -- Formatting
  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        -- Disable for large files
        local max = 1024 * 256 -- 256 KiB
        local uv = vim.uv or vim.loop
        local ok, stats = pcall(uv.fs_stat, vim.api.nvim_buf_get_name(bufnr))
        if ok and stats and stats.size > max then return nil end
        return { timeout_ms = 1000, lsp_fallback = true }
      end,
      formatters_by_ft = {
        lua = { "stylua" },
        javascript = { "prettierd", "prettier", "biome" },
        typescript = { "prettierd", "prettier", "biome" },
        javascriptreact = { "prettierd", "prettier", "biome" },
        typescriptreact = { "prettierd", "prettier", "biome" },
        json = { "prettierd", "prettier" },
        yaml = { "yamlfmt", "prettier" },
        markdown = { "prettierd", "prettier" },
        python = { "ruff_format", "black" },
        go = { "gofumpt", "gofmt" },
        sh = { "shfmt" },
      },
    },
  },

  -- Completion
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-buffer",
      "saadparwaiz1/cmp_luasnip",
      "L3MON4D3/LuaSnip",
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      require("luasnip.loaders.from_vscode").lazy_load()

      luasnip.config.setup({ region_check_events = "InsertEnter", delete_check_events = "TextChanged,InsertLeave" })

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = {
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "path" },
          { name = "buffer" },
        },
        experimental = { ghost_text = true },
      })

      -- Integrate with autopairs on completion confirm
      local ok, cmp_autopairs = pcall(require, "nvim-autopairs.completion.cmp")
      if ok then
        cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
      end
    end,
  },
}
